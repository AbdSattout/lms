package app.lms.quiz.dto;

import java.util.List;

public record FinalQuizQuestionResultResponse(

        Long questionId,

        String content,

        List<String> options,

        Integer selectedAnswerIndex,

        Integer correctAnswerIndex,

        Boolean correct
) {
}