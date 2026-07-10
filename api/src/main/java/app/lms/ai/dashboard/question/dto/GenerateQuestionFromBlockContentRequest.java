package app.lms.ai.dashboard.question.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record GenerateQuestionFromBlockContentRequest(
        @NotBlank
        @Size(max = 15000)

        String blockContent
) {
}