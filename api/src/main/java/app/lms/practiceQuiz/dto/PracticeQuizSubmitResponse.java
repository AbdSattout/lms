package app.lms.practiceQuiz.dto;

import app.lms.gamification.dto.GamificationAwardResponse;

import java.util.List;

public record PracticeQuizSubmitResponse(
        Long attemptId,
        Integer score,
        Integer total,
        List<PracticeQuizQuestionResultResponse> results,
        List<GamificationAwardResponse> rewards
) {
}
