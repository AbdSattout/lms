package app.lms.chapter.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record ReorderChaptersRequest(

        @NotEmpty
        List<Long> chapterIds

) {
}