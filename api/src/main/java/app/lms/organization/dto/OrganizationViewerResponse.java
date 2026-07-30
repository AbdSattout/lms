package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import lombok.Builder;

@Builder
public record OrganizationViewerResponse(

        boolean joined,
        Role role

) {}
