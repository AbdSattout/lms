package app.lms.ai.mobile.quiz.dto;

public record RandomQuizSubmitResponse(
        Long attemptId,
        Integer score,
        Integer total
) {
}