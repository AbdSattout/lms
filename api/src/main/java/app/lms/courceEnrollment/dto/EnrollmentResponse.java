package app.lms.courceEnrollment.dto;

import lombok.Builder;

import java.time.LocalDateTime;

@Builder
public record EnrollmentResponse(

        Long courseId,
        String courseTitle,
        LocalDateTime enrolledAt

) {}
