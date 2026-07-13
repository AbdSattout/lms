package app.lms.practiceQuiz.dto;

import java.util.List;

public record PracticeQuizQuestionResultResponse(
        Long questionId,
        String content,
        List<String> options,
        Integer selectedAnswerIndex,
        Integer correctAnswerIndex,
        Boolean correct
) {
}