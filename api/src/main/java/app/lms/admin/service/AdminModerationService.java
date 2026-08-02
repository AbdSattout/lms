package app.lms.admin.service;

import app.lms.admin.model.Admin;
import app.lms.common.exception.BadRequestException;
import app.lms.moderation.dto.BanRequest;
import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.user.model.User;
import app.lms.user.moderation.model.UserModeration;
import app.lms.user.moderation.repository.UserModerationRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminModerationService {

    private final AdminModerationAccessService accessService;

    private final OrganizationModerationRepository organizationModerationRepository;
    private final UserModerationRepository userModerationRepository;

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
