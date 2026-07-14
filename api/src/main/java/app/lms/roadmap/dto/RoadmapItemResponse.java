package app.lms.roadmap.dto;

import app.lms.course.dto.CourseResponse;

public record RoadmapItemResponse(

        Long id,

        Integer position,

        CourseResponse course
) {
}
