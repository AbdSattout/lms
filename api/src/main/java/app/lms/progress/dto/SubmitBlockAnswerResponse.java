package app.lms.progress.dto;

import app.lms.progress.enums.NextStepType;

public record SubmitBlockAnswerResponse(
        NextStepType nextType,
        Long nextBlockId,
        Long nextLessonId,
        Long nextChapterId,
        Long quizId,
        String message
) {
}