package app.lms.enrollment.dto;

import app.lms.enrollment.enums.EnrollmentStatus;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Builder;

import java.time.LocalDateTime;

@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public record CourseEnrollmentResponse(

        Long id,
        Long courseId,
        String courseTitle,
        LocalDateTime enrolledAt,
        EnrollmentStatus status,
        Boolean placementTestCompleted,
        Integer progressPercentage,
        Long currentChapterId,
        Long currentLessonId,
        Long currentBlockId,
        LocalDateTime completedAt

) {}
