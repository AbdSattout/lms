package app.lms.admin.service;

import app.lms.admin.dto.BannedOrganizationResponse;
import app.lms.admin.dto.BannedUserResponse;
import app.lms.admin.mapper.AdminModerationMapper;
import app.lms.admin.model.Admin;
import app.lms.common.exception.BadRequestException;
import app.lms.moderation.dto.BanRequest;
import app.lms.moderation.service.BanNotificationEmailService;
import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.user.model.User;
import app.lms.user.moderation.model.UserModeration;
import app.lms.user.moderation.repository.UserModerationRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminModerationService {

    private final AdminModerationAccessService accessService;

    private final OrganizationModerationRepository organizationModerationRepository;
    private final UserModerationRepository userModerationRepository;
    private final BanNotificationEmailService banNotificationEmailService;
    private final AdminModerationMapper adminModerationMapper;

    public void banUser(
            Long userId,
            BanRequest request,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        LocalDateTime now =
                LocalDateTime.now();

        LocalDateTime expiresAt =
                request.expiresAtFrom(
                        now
                );

        UserModeration existingBan =
                userModerationRepository
                        .findByUserId(
                                user.getId()
                        )
                        .orElse(null);

        if (existingBan != null) {
            validateBanIsExpired(
                    existingBan.getExpiresAt(),
                    now,
                    "User is already banned"
            );

            existingBan.setBannedBy(admin);
            existingBan.setReason(request.reason());
            existingBan.setExpiresAt(expiresAt);
            banNotificationEmailService.sendUserBan(
                    user,
                    request.reason(),
                    expiresAt
            );
            return;
        }

        userModerationRepository.save(
                UserModeration.builder()
                        .user(user)
                        .bannedBy(admin)
                        .reason(request.reason())
                        .expiresAt(expiresAt)
                        .build()
        );

        banNotificationEmailService.sendUserBan(
                user,
                request.reason(),
                expiresAt
        );
    }

    public void unbanUser(
            Long userId,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        UserModeration ban =
                accessService.getUserModerationBan(
                        user
                );

        userModerationRepository.delete(
                ban
        );

    }

    public void banOrganization(
            Long organizationId,
            BanRequest request,
            Long adminId
    ){
        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        LocalDateTime now =
                LocalDateTime.now();

        LocalDateTime expiresAt =
                request.expiresAtFrom(
                        now
                );

        OrganizationModeration existingBan =
                organizationModerationRepository
                        .findByOrganizationId(
                                organization.getId()
                        )
                        .orElse(null);

        if (existingBan != null) {
            validateBanIsExpired(
                    existingBan.getExpiresAt(),
                    now,
                    "Organization is already banned "
            );

            existingBan.setBannedBy(admin);
            existingBan.setReason(request.reason());
            existingBan.setExpiresAt(expiresAt);
            banNotificationEmailService.sendOrganizationBan(
                    organization,
                    request.reason(),
                    expiresAt
            );
            return;
        }

        organizationModerationRepository.save(
                OrganizationModeration.builder()
                        .organization(organization)
                        .bannedBy(admin)
                        .reason(request.reason())
                        .expiresAt(expiresAt)
                        .build()
        );

        banNotificationEmailService.sendOrganizationBan(
                organization,
                request.reason(),
                expiresAt
        );

    }

    public Page<BannedUserResponse> getBannedUsers(
            Long adminId,
            Pageable pageable
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        return userModerationRepository
                .findAllActive(moderationPageable(pageable))
                .map(adminModerationMapper::toBannedUserResponse);
    }

    public void unbanOrganization(
            Long organizationId,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        OrganizationModeration ban =
                accessService.getOrganizationModerationBan(
                        organization
                );

        organizationModerationRepository.delete(
                ban
        );
    }

    public Page<BannedOrganizationResponse> getBannedOrganizations(
            Long adminId,
            Pageable pageable
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        return organizationModerationRepository
                .findAllActive(moderationPageable(pageable))
                .map(adminModerationMapper::toBannedOrganizationResponse);
    }

    private Pageable moderationPageable(
            Pageable pageable
    ) {

        Sort sort =
                moderationSort(
                        pageable.getSort()
                );

        if (pageable.isUnpaged()) {
            return Pageable.unpaged(
                    sort
            );
        }

        return PageRequest.of(
                pageable.getPageNumber(),
                pageable.getPageSize(),
                sort
        );
    }

    private Sort moderationSort(
            Sort sort
    ) {

        if (sort.isUnsorted()) {
            return Sort.by(
                    Sort.Direction.DESC,
                    "createdAt"
            );
        }

        return Sort.by(
                sort.stream()
                        .map(order -> order.withProperty(
                                moderationSortProperty(
                                        order.getProperty()
                                )
                        ))
                        .toList()
        );
    }

    private String moderationSortProperty(
            String property
    ) {

        return switch (property) {
            case "baseEntity.createdAt" -> "createdAt";
            case "baseEntity.updatedAt" -> "updatedAt";
            default -> property;
        };
    }

    private void validateBanIsExpired(
            LocalDateTime expiresAt,
            LocalDateTime now,
            String message
    ) {

        if (
                expiresAt == null
                        || expiresAt.isAfter(now)
        ) {
            throw new BadRequestException(
                    message
            );
        }
    }

}
