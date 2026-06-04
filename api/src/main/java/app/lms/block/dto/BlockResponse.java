package app.lms.block.dto;

import app.lms.block.enums.BlockType;

public record BlockResponse(

        Long id,

        String title,

        BlockType type,

        String content,

        Integer position,

        Boolean isPublished

) {
}
