package app.lms.block.dto;

import app.lms.block.enums.BlockType;
import app.lms.question.dto.QuestionResponse;

public record BlockResponse(


        Long id,
        String title,
        String content,
        Integer position,
        QuestionResponse question

) {
}
