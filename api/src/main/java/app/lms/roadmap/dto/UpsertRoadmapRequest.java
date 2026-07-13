package app.lms.roadmap.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record UpsertRoadmapRequest(

        @NotEmpty
        List<Long> courseIds
) {
}
