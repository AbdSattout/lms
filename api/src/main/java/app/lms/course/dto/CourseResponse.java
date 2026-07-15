package app.lms.course.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.course.enums.CourseStatus;
import lombok.Builder;

@Builder
public record CourseResponse(

        Long id,
        String title,
        String slug,
        String description,
        String coverUrl,
        String organizationName,
        CourseStatus status,
        BaseEntityResponse baseEntity

) {}
