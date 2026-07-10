package app.lms.ai.dashboard.text.dto;

import app.lms.ai.dashboard.text.enums.AiTextAction;
import app.lms.ai.dashboard.text.enums.AiTextTone;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record GenerateAiTextRequest(
        @NotBlank
        @Size(max = 10000)
        String text,

        @NotNull
        AiTextAction action,

        AiTextTone tone
) {
}