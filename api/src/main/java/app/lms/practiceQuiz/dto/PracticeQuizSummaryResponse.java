package app.lms.practiceQuiz.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.enums.QuestionDifficulty;

public record PracticeQuizSummaryResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        QuestionDifficulty difficulty,
        Integer questionCount,
        BaseEntityResponse baseEntity
) {
}
