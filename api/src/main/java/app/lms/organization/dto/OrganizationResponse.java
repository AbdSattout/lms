package app.lms.organization.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.enums.Visibility;
import lombok.Builder;

@Builder
public record OrganizationResponse(

        Long id,
        String name,
        String slug,
        String description,
        String image,
        Visibility visibility,
        String ownerName,
        Long membersCount,
        BaseEntityResponse baseEntity

) {}
