package app.lms.roadmap.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationResponse;

import java.util.List;

public record RoadmapResponse(

        Long id,

        OrganizationResponse organization,

        List<RoadmapItemResponse> items,

        BaseEntityResponse baseEntity
) {
}
