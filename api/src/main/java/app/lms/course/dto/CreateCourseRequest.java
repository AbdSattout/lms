package app.lms.course.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class CreateCourseRequest {

    @NotBlank
    private String title;

    @NotBlank
    @Pattern(
            regexp = "^[a-z0-9-]+$",
            message = "Invalid slug"
    )
    private String slug;

    private String description;

    private String coverUrl;
}
