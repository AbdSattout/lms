package app.lms.faq.dto;

import app.lms.common.dto.BaseEntityResponse;

public record CourseFaqResponse(
        Long id,
        String question,
        String answer,
        Integer position,
        BaseEntityResponse baseEntity
) {
}
