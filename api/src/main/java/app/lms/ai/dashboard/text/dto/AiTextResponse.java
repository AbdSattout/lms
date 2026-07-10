package app.lms.ai.dashboard.text.dto;

import app.lms.ai.dashboard.text.enums.AiTextAction;
import app.lms.ai.dashboard.text.enums.AiTextTone;

public record AiTextResponse(
        AiTextAction action,
        AiTextTone tone,
        String result
) {
}