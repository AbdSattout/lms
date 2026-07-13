package app.lms.quiz.dto;

import app.lms.question.dto.QuestionResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record QuizResponse(
        Long id,
        String title,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionResponse> questions
) {}
