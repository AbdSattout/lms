package app.lms.courceEnrollment.dto;

import java.time.LocalDateTime;

public record CourseProgressResponse(

        Long currentLessonId,

        Long currentBlockId,

        Integer progressPercentage,

        Boolean completed,

        LocalDateTime completedAt

) {
}
