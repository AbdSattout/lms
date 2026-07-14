package app.lms.block.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.dto.QuestionPublicResponse;

public record BlockPublicResponse(

        Long id,
        String title,
        String content,
        Integer position,
        QuestionPublicResponse question,
        BaseEntityResponse baseEntity

) {
}
