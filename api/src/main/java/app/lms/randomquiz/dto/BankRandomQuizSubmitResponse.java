package app.lms.randomquiz.dto;

import java.util.List;

public record BankRandomQuizSubmitResponse(

        Long attemptId,

        Integer score,

        Integer total,

        List<BankRandomQuizQuestionResultResponse> results
) {
}