package app.lms.question.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.util.List;

public record QuestionPublicResponse(

        Long id,

        String content,

        List<String> options,

        BaseEntityResponse baseEntity

) {
}
