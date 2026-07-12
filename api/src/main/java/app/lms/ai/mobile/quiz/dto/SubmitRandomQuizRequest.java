package app.lms.ai.mobile.quiz.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record SubmitRandomQuizRequest(
        @NotEmpty
        List<@Valid SubmitRandomQuizAnswer> answers
) {
}