package app.lms.organization.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.enums.Visibility;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

@Builder
public record OrganizationResponse(

        Long id,
        String name,
        String slug,
        String description,
        String image,
        Visibility visibility,
        Boolean verified,
        String ownerName,
        Long membersCount,
        Long coursesCount,
        @JsonInclude(JsonInclude.Include.NON_NULL)
        OrganizationViewerResponse viewer,
        BaseEntityResponse baseEntity

) {}
