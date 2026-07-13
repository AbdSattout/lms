package app.lms.quiz.dto;

import java.util.List;

public record FinalQuizSubmitResponse(

        Long attemptId,

        Integer score,

        Integer total,

        List<FinalQuizQuestionResultResponse> results
) {
}