package app.lms.organization.dto;

import app.lms.organization.enums.Visibility;
import lombok.Builder;

@Builder
public record OrganizationSummaryResponse(

        Long id,
        String name,
        String slug,
        String description,
        String image,
        Visibility visibility

) {}
