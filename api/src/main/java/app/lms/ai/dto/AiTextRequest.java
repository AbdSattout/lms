package app.lms.ai.dto;

import app.lms.ai.enums.AiTextAction;
import app.lms.ai.enums.AiTextTone;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record AiTextRequest(
        @NotBlank
        @Size(max = 10000)
        String text,

        @NotNull
        AiTextAction action,

        AiTextTone tone
) {
}