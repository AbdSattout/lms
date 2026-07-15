package app.lms.practiceQuiz.dto;

import java.util.List;

public record PracticeQuizSubmitResponse(
        Integer score,
        Integer total,
        List<PracticeQuizQuestionResultResponse> results
) {
}
