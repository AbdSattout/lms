package app.lms.block.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record CreateBlockRequest(

        @NotBlank
        String title,


        String content,

        @NotNull
        @Positive
        Long questionId

) {
}
