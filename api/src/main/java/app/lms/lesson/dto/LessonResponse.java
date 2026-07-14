package app.lms.lesson.dto;

import app.lms.common.dto.BaseEntityResponse;

public record LessonResponse(

        Long id,
        String title,
        Integer position,
        BaseEntityResponse baseEntity

) {
}
