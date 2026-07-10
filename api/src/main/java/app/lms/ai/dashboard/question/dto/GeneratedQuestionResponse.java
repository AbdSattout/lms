package app.lms.ai.dashboard.question.dto;

import java.util.List;

public record GeneratedQuestionResponse(
        String content,
        List<String> options,
        Integer correctAnswerIndex,
        Boolean shuffleOptions
) {
}