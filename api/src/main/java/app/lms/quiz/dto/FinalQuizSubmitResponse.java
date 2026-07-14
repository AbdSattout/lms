package app.lms.quiz.dto;

import app.lms.gamification.dto.GamificationAwardResponse;

import java.util.List;

public record FinalQuizSubmitResponse(

        Long attemptId,

        Integer score,

        Integer total,

        List<FinalQuizQuestionResultResponse> results,

        List<GamificationAwardResponse> rewards
) {
}
