package app.lms.ai.mobile.quiz.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record RandomQuizQuestionResultResponse(

        Long questionId,

        String content,

        List<String> options,

        Integer selectedAnswerIndex,

        Integer correctAnswerIndex,

        Boolean correct,

        BaseEntityResponse baseEntity

) {
}
