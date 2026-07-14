package app.lms.lesson.dto;

import app.lms.common.dto.BaseEntityResponse;

public record LessonDetailsResponse(
        Long id,
        String title,
        Integer position,
        Long chapterId,
        Long courseId,
        Long organizationId,
        BaseEntityResponse baseEntity
) {
}
