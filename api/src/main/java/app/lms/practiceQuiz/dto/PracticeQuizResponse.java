package app.lms.practiceQuiz.dto;

import app.lms.question.dto.QuestionResponse;

import java.util.List;

public record PracticeQuizResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        List<QuestionResponse> questions
) {
}