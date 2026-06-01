package app.lms.chapter.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateChapterRequest(
        @NotBlank
        String title
) {
}