package app.lms.ai.dto;

import app.lms.ai.enums.AiTextAction;
import app.lms.ai.enums.AiTextTone;

public record AiTextResponse(
        AiTextAction action,
        AiTextTone tone,
        String result
) {
}