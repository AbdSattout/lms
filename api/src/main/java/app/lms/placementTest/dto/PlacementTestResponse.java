package app.lms.placementTest.dto;

import app.lms.common.dto.BaseEntityResponse;

public record PlacementTestResponse(
        Boolean completed,
        Integer correctAnswers,
        Integer totalAnswers,
        Integer remainingHearts,
        PlacementTestQuestionResponse question,
        Long startBlockId,
        Long startLessonId,
        Long startChapterId,
        Integer progressPercentage,
        String message,
        BaseEntityResponse baseEntity
) {
}
