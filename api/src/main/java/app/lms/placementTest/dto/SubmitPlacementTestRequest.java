package app.lms.placementTest.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SubmitPlacementTestRequest(
        @NotNull
        @Min(0)
        Integer answerIndex
) {
}
