package app.lms.course.dto;

import lombok.Builder;

@Builder
public record CourseResponse(

        Long id,
        String title,
        String description,
        String coverUrl,
        String organizationName

) {}
