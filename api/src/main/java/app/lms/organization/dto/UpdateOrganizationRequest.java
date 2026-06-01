package app.lms.organization.dto;

import app.lms.organization.emums.Visibility;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateOrganizationRequest {

    @Size(max = 100)
    private String name;

    @Size(max = 5000)
    private String description;

    private String image;

    private Visibility visibility;
}
