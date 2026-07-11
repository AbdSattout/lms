package app.lms.ai.mobile.quiz.dto;

import java.util.List;

public record RandomQuizQuestionResultResponse(

        Long questionId,

        String content,

        List<String> options,

        Integer selectedAnswerIndex,

        Integer correctAnswerIndex,

        Boolean correct

) {
}