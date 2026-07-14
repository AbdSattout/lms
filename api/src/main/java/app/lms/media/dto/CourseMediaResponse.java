package app.lms.media.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.enums.FileType;

public record CourseMediaResponse(

        Long id,

        String name,

        String url,

        FileType type,

        Long courseId,

        BaseEntityResponse baseEntity
) {
}
