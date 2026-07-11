package app.lms.ai.mobile.quiz.dto;

import java.util.List;

public record GeneratedRandomQuizQuestion(
        Long sourceQuestionId,
        String content,
        List<String> options,
        Integer correctAnswerIndex
) {
}