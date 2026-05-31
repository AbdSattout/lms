package app.lms.course.mapper;

import app.lms.course.dto.CourseResponse;
import app.lms.course.model.Course;
import org.springframework.stereotype.Component;

@Component
public class CourseMapper {

    public CourseResponse toResponse(
            Course course
    ) {

        return CourseResponse.builder()
                .id(course.getId())
                .title(course.getTitle())
                .description(course.getDescription())
                .coverUrl(course.getCoverUrl())
                .organizationName(
                        course.getOrganization().getName()
                )
                .build();
    }
}
