package app.lms.lesson.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record ReorderLessonsRequest(

        @NotEmpty
        List<Long> lessonIds

) {
}
