package app.lms.organization.dto;

import app.lms.organization.enums.Visibility;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

@Builder
public record OrganizationSummaryResponse(

        Long id,
        String name,
        String slug,
        String description,
        String image,
        Visibility visibility,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        OrganizationViewerResponse viewer

) {}
