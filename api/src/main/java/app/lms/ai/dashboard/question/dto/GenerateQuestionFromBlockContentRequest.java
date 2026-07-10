package app.lms.ai.dashboard.question.dto;

import jakarta.validation.constraints.NotBlank;

public record GenerateQuestionFromBlockContentRequest(
        @NotBlank
        String blockContent
) {
}