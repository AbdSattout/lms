package app.lms.admin.service;

import app.lms.admin.enums.AdminRole;
import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import app.lms.user.moderation.model.UserModeration;
import app.lms.user.moderation.repository.UserModerationRepository;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminModerationAccessService {

    private final UserRepository userRepository;
    private final AdminRepository adminRepository;
    private final OrganizationRepository organizationRepository;
    private final OrganizationModerationRepository organizationModerationRepository;
    private final UserModerationRepository userModerationRepository;

    public User getUser(
            Long userId
    ) {

        return userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "User not found"
                        )
                );
    }

    public Admin getAdmin(
            Long adminId
    ) {

        return adminRepository
                .findById(adminId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Admin not found"
                        )
                );
    }

    public void validateAdmin(
            Admin admin
    ) {
        boolean allowed =
                admin.getRole() == AdminRole.SUPER_ADMIN
                        || admin.getRole() == AdminRole.MODERATOR;

        if (!allowed) {
            throw new ForbiddenException(
                    "Access denied"
            );
        }

    }

    public Organization getOrganization(
            Long organizationId
    ) {

        return organizationRepository
                .findById(organizationId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization not found"
                        )
                );
    }

    public void validateUserModerationNotBanned(
            User user
    ) {

        if (
                userModerationRepository.existsByUserId(
                        user.getId()
                )
        ) {

            throw new BadRequestException(
                    "User is already banned"
            );
        }

    }

    public UserModeration getUserModerationBan(
            User user
    ) {

        return userModerationRepository
                .findByUserId(
                        user.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Ban not found"
                        )
                );
    }

    public void validateOrganizationModerationNotBanned(
            Organization organization
    ) {

        if (
                organizationModerationRepository.existsByOrganizationId(
                        organization.getId()
                )
        ) {

            throw new BadRequestException(
                    "Organization is already banned "
            );
        }

    }

}
