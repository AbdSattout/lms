package app.lms.progress.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SubmitBlockAnswerRequest(

        @NotNull
        @Min(0)
        Integer answerIndex

) {
}