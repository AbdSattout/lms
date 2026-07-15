package app.lms.randomquiz.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record BankRandomQuizSubmitResponse(

        Long attemptId,

        Integer score,

        Integer total,

        List<BankRandomQuizQuestionResultResponse> results,

        BaseEntityResponse baseEntity
) {
}
