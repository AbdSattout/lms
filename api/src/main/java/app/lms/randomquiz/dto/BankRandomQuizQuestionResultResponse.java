package app.lms.randomquiz.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record BankRandomQuizQuestionResultResponse(

        Long questionId,

        String content,

        List<String> options,

        Integer selectedAnswerIndex,

        Integer correctAnswerIndex,

        Boolean correct,

        BaseEntityResponse baseEntity
) {
}
