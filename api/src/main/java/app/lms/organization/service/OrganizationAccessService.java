package app.lms.organization.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class OrganizationAccessService {

    private final OrganizationRepository organizationRepository;

    public Organization getBySlug(
            String slug
    ) {

        return organizationRepository
                .findBySlug(slug)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization not found"
                        )
                );
    }

    public Organization getOwnedOrganization(
            String slug,
            User user
    ) {

        Organization organization =
                getBySlug(slug);

        if (!organization.getOwner().getId().equals(user.getId())) {
            throw new ForbiddenException(
                    "You are not allowed"
            );
        }

        return organization;
    }
}