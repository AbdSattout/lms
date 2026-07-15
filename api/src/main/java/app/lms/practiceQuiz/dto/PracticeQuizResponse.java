package app.lms.practiceQuiz.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record PracticeQuizResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionResponse> questions,
        BaseEntityResponse baseEntity
) {
}
