package app.lms.roadmap.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.enums.RoadmapStatus;

import java.util.List;

public record RoadmapResponse(

        Long id,

        String name,

        String description,

        RoadmapStatus status,

        OrganizationResponse organization,

        List<RoadmapItemResponse> items,

        RoadmapFollowStatus followStatus,

        BaseEntityResponse baseEntity
) {
}
