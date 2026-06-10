package app.lms.courceEnrollment.dto;

import java.time.LocalDateTime;

public record CourseProgressResponse(

        Long lastLessonId,

        Long lastBlockId,

        Integer progressPercentage,

        Boolean completed,

        LocalDateTime completedAt

) {
}