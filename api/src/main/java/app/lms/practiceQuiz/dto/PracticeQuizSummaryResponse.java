package app.lms.practiceQuiz.dto;

public record PracticeQuizSummaryResponse(
        Long id,
        String title,
        String description,
        Long courseId,
        Integer questionCount
) {
}