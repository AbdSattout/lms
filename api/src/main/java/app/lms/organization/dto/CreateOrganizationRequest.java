package app.lms.organization.dto;


import app.lms.organization.enums.Visibility;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class CreateOrganizationRequest {
    @NotBlank
    @Size(max = 100)
    private String name;

    @NotBlank
    @Pattern(
            regexp = "^[a-z0-9-]+$",
            message = "Invalid slug"
    )
    private String slug;

    @Size(max = 5000)
    private String description;

    private Visibility visibility;
}
