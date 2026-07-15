package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.course.enums.CourseNodeStatus;

public record CourseBlockMapResponse(
        Long id,
        String title,
        Integer position,
        CourseNodeStatus status,
        BaseEntityResponse baseEntity
) {
}
