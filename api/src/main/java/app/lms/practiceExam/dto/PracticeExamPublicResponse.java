package app.lms.practiceExam.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record PracticeExamPublicResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionPublicResponse> questions,
        BaseEntityResponse baseEntity
) {
}
