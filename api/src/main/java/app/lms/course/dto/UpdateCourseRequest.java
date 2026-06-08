package app.lms.course.dto;

import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class UpdateCourseRequest {

    private String title;

    @Pattern(
            regexp = "^[a-z0-9-]+$",
            message = "Invalid slug"
    )
    private String slug;

    private String description;

    private String coverUrl;

}
