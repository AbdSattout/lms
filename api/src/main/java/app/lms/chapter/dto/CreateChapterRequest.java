package app.lms.chapter.dto;

import jakarta.validation.constraints.NotBlank;

public record CreateChapterRequest(

        @NotBlank
        String title

) {
}