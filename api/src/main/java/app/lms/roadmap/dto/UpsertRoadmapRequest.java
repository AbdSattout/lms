package app.lms.roadmap.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

public record UpsertRoadmapRequest(

        @NotBlank
        @Size(max = 255)
        String name,

        @Size(max = 5000)
        String description,

        @NotEmpty
        List<Long> courseIds
) {
}
