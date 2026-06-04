package app.lms.lesson.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateLessonRequest(

        @NotBlank
        String title
) {
}
