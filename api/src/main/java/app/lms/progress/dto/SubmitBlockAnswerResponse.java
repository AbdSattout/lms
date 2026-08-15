package app.lms.progress.dto;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.progress.enums.NextStepType;

import java.util.List;

public record SubmitBlockAnswerResponse(
        NextStepType nextType,
        Long nextBlockId,
        Long nextLessonId,
        Long nextChapterId,
        Long quizId,
        String message,
        List<GamificationAwardResponse> rewards,
        List<UserBadgeResponse> badges
) {
}
