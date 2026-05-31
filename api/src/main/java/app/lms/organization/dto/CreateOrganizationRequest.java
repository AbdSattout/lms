package app.lms.organization.dto;


import app.lms.organization.emums.Visibility;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class CreateOrganizationRequest {
    @NotBlank
    private String name;

    private String description;

    private String image;

    private Visibility visibility;
}
