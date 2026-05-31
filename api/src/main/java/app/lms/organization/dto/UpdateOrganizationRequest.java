package app.lms.organization.dto;

import app.lms.organization.emums.Visibility;
import lombok.Data;

@Data
public class UpdateOrganizationRequest {

    private String name;

    private String description;

    private String image;

    private Visibility visibility;
}
