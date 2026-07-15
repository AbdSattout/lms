package app.lms.quiz.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record FinalQuizResponse(
        Long quizId,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionPublicResponse> questions,
        BaseEntityResponse baseEntity
) {
}
