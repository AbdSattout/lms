package app.lms.placementTest.dto;

public record SubmitPlacementTestResponse(
        Boolean correct,
        Boolean completed,
        Integer correctAnswers,
        Integer totalAnswers,
        PlacementTestQuestionResponse nextQuestion,
        Long startBlockId,
        Long startLessonId,
        Long startChapterId,
        Integer progressPercentage,
        String message
) {
}
