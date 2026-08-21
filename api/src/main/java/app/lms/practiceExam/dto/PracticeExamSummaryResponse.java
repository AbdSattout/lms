package app.lms.practiceExam.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.practiceExam.enums.PracticeExamStatus;
import app.lms.question.enums.QuestionDifficulty;

public record PracticeExamSummaryResponse(
        Long id,
        String title,
        String description,
        Integer timeLimitMinutes,
        PracticeExamStatus status,
        boolean hasStarted,
        Long courseId,
        QuestionDifficulty difficulty,
        Integer questionCount,
        BaseEntityResponse baseEntity
) {
}
