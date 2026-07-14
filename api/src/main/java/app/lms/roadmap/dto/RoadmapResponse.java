package app.lms.roadmap.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record RoadmapResponse(

        Long id,

        Long organizationId,

        String organizationSlug,

        List<RoadmapItemResponse> items,

        BaseEntityResponse baseEntity
) {
}
