package app.lms.organization.organizationInvite.dto;

import app.lms.organization.enums.Visibility;
import app.lms.user.dto.UserResponse;
import lombok.Builder;

@Builder
public record OrganizationInviteOrganizationResponse(

        Long id,
        String name,
        String slug,
        String description,
        String imageUrl,
        Visibility visibility,
        UserResponse owner

) {}
