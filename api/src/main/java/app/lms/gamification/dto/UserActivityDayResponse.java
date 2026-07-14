package app.lms.gamification.dto;

import app.lms.common.dto.BaseEntityResponse;
import lombok.Builder;

import java.time.LocalDate;

@Builder
public record UserActivityDayResponse(
        LocalDate date,
        Integer xpEarned,
        Integer completedBlocks,
        Integer completedLessons,
        Integer completedChapters,
        Integer completedCourses,
        Integer completedPracticeQuizzes,
        Integer completedFinalQuizzes,
        Integer completedQuizzes,
        Integer correctQuestions,
        Integer enrollments,
        Integer totalActions,
        BaseEntityResponse baseEntity
) {
}
