package app.lms.randomquiz.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record BankRandomQuizResponse(

        Long attemptId,

        QuestionDifficulty difficulty,

        List<QuestionPublicResponse> questions,

        BaseEntityResponse baseEntity
) {
}
