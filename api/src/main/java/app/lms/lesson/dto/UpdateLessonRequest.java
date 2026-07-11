package app.lms.lesson.dto;

import jakarta.validation.constraints.Positive;

public record UpdateLessonRequest(

        String title,
        @Positive
        Long chapterId
) {
}
