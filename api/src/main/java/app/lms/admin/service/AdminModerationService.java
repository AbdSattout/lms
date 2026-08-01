package app.lms.admin.service;

import app.lms.admin.model.Admin;
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

        accessService.validateUserModerationNotBanned(
                user
        );

        userModerationRepository.save(
                UserModeration.builder()
                        .user(user)
                        .bannedBy(admin)
                        .reason(request.reason())
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

        accessService.validateOrganizationModerationNotBanned(
                organization
        );

        organizationModerationRepository.save(
                OrganizationModeration.builder()
                        .organization(organization)
                        .bannedBy(admin)
                        .reason(request.reason())
                        .build()
        );

    }


}
