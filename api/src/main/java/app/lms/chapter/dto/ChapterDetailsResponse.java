package app.lms.chapter.dto;

import app.lms.common.dto.BaseEntityResponse;

public record ChapterDetailsResponse(
        Long id,
        String title,
        Integer position,
        Long courseId,
        Long organizationId,
        BaseEntityResponse baseEntity
) {
}
