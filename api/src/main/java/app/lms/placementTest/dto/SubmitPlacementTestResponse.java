package app.lms.placementTest.dto;

import app.lms.common.dto.BaseEntityResponse;

public record SubmitPlacementTestResponse(
        Boolean correct,
        Boolean completed,
        Integer correctAnswers,
        Integer totalAnswers,
        Integer remainingHearts,
        PlacementTestQuestionResponse nextQuestion,
        Long startBlockId,
        Long startLessonId,
        Long startChapterId,
        Integer progressPercentage,
        String message,
        BaseEntityResponse baseEntity
) {
}
