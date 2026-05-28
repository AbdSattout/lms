package app.lms.organization.dto;

import app.lms.organization.emums.Visibility;
import lombok.Builder;

@Builder
public record OrganizationResponse(

        Long id,
        String name,
        String description,
        String image,
        Visibility visibility,
        String ownerName

) {}