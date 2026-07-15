package app.lms.placementTest.dto;

public record PlacementTestResponse(
        Boolean completed,
        Integer correctAnswers,
        Integer totalAnswers,
        PlacementTestQuestionResponse question,
        Long startBlockId,
        Long startLessonId,
        Long startChapterId,
        Integer progressPercentage,
        String message
) {
}
