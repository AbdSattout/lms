package app.lms.block.dto;

import app.lms.block.enums.BlockType;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateBlockRequest(

        @NotBlank
        String title,

        @NotNull
        BlockType type,

        String content

) {
}
