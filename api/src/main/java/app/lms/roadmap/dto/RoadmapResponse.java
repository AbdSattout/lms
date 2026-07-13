package app.lms.roadmap.dto;

import java.util.List;

public record RoadmapResponse(

        Long id,

        Long organizationId,

        String organizationSlug,

        List<RoadmapItemResponse> items
) {
}
