package app.lms.block.dto;

import app.lms.block.enums.BlockType;
import app.lms.question.dto.QuestionPublicResponse;

public record BlockPublicResponse(

        Long id,
        String title,
        BlockType type,
        String content,
        Integer position,
        QuestionPublicResponse question

) {
}
