package app.lms.quiz.dto;

import app.lms.question.dto.QuestionPublicResponse;

import java.util.List;

public record FinalQuizResponse(
        Long quizId,
        Long courseId,
        List<QuestionPublicResponse> questions
) {
}