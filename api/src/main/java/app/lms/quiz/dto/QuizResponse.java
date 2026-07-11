package app.lms.quiz.dto;

import app.lms.question.dto.QuestionResponse;

import java.util.List;

public record QuizResponse(
        Long id,
        String title,
        Long courseId,
        List<QuestionResponse> questions
) {}
