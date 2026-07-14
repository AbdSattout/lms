package app.lms.block.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionResponse;

public record BlockResponse(


        Long id,
        String title,
        String content,
        Integer position,
        QuestionResponse question,
        BaseEntityResponse baseEntity

) {
}
