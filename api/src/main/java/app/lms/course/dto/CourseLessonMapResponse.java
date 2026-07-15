package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.course.enums.CourseNodeStatus;

import java.util.List;

public record CourseLessonMapResponse(
        Long id,
        String title,
        Integer position,
        CourseNodeStatus status,
        List<CourseBlockMapResponse> blocks,
        BaseEntityResponse baseEntity
) {
}
