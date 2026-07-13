package app.lms.practiceQuiz.dto;

import app.lms.question.dto.QuestionPublicResponse;

import java.util.List;

public record PracticeQuizPublicResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        List<QuestionPublicResponse> questions
) {
}