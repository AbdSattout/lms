package app.lms.block.dto;

import jakarta.validation.constraints.Positive;

public record UpdateBlockRequest(

        String title,

        String content,

        @Positive
        Long questionId

) {
}