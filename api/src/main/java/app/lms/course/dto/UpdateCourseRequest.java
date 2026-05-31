package app.lms.course.dto;

import lombok.Data;

@Data
public class UpdateCourseRequest {

    private String title;

    private String description;
}
