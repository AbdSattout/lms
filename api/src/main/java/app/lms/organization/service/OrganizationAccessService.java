package app.lms.organization.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.OrganizationBan.repository.OrganizationBanRepository;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrganizationAccessService {

    private final OrganizationRepository organizationRepository;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final OrganizationModerationRepository organizationModerationRepository;
    private final OrganizationBanRepository organizationBanRepository;

    public Organization getBySlug(
            String slug
    ) {

        Organization organization =
                organizationRepository
                .findBySlug(slug)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization not found"
                        )
                );

        validateNotBanned(organization);

        return organization;
    }

    public Organization getById(
            Long organizationId
    ) {

        Organization organization =
                organizationRepository
                .findById(organizationId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization not found"
                        )
                );

        validateNotBanned(organization);

        return organization;
    }

    public Organization getManageableOrganization(
            String slug,
            User user
    ) {

        Organization organization =
                getBySlug(slug);

        organizationMemberAccessService
                .validateManager(
                        organization.getId(),
                        user.getId()
                );

        return organization;
    }

    public Organization getManageableOrganization(
            Long organizationId,
            User user
    ) {

        Organization organization =
                getById(organizationId);

        organizationMemberAccessService
                .validateManager(
                        organization.getId(),
                        user.getId()
                );

        return organization;
    }

    public void validateNotBanned(
            Organization organization
    ) {

        if (
                organizationModerationRepository.existsByOrganizationId(
                        organization.getId()
                )
        ) {

            throw new ForbiddenException(
                    "This organization has been banned."
            );

        }

    }

    public void validateUserNotBannedFromOrg(
            Organization organization,
            User user
    ) {

        if (
                organizationBanRepository.existsByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
        ) {

            throw new ForbiddenException(
                    "This user has been banned from this organization"
            );

        }

    }
}
