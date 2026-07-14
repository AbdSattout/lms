package app.lms.ai.mobile.quiz.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record RandomQuizSubmitResponse(
        Long attemptId,
        Integer score,
        Integer total,
        List<RandomQuizQuestionResultResponse>results,
        BaseEntityResponse baseEntity
) {
}
