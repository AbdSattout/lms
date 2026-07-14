package app.lms.question.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record QuestionResponse(
        Long id,
        String content,
        List<String> options,
        Integer correctAnswerIndex,
        QuestionDifficulty difficulty,
        Long courseId,
        BaseEntityResponse baseEntity
) {
}
