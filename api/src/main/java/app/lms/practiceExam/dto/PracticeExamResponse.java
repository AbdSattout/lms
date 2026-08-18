package app.lms.practiceExam.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.practiceExam.enums.PracticeExamStatus;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record PracticeExamResponse(
        Long id,
        String title,
        String description,
        Integer timeLimitMinutes,
        PracticeExamStatus status,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionResponse> questions,
        BaseEntityResponse baseEntity
) {
}
