package app.lms.enrollment.dto;

import java.time.LocalDateTime;

public record CourseProgressResponse(

        Long currentChapterId,

        Long currentLessonId,

        Long currentBlockId,

        Integer progressPercentage,

        Boolean completed,

        LocalDateTime completedAt

) {
}
