package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.course.enums.CourseNodeStatus;

import java.util.List;

public record CourseChapterMapResponse(
        Long id,
        String title,
        Integer position,
        CourseNodeStatus status,
        List<CourseLessonMapResponse> lessons,
        BaseEntityResponse baseEntity
) {
}
