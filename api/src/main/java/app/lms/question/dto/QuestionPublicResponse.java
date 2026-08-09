package app.lms.question.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.util.List;

public record QuestionPublicResponse(

        Long id,

        String content,

        List<String> options,

        QuestionDifficulty difficulty,

        BaseEntityResponse baseEntity

) {
}
