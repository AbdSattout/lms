package app.lms.ai.mobile.quiz.dto;

import app.lms.question.dto.QuestionPublicResponse;

import java.util.List;

public record RandomQuizResponse(
        Long attemptId,
        List<QuestionPublicResponse> questions
) {
}