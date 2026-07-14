package app.lms.practiceQuiz.dto;

import java.util.List;

public record PracticeQuizSubmitResponse(
        Long attemptId,
        Integer score,
        Integer total,
        List<PracticeQuizQuestionResultResponse> results
) {
}