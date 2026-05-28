package app.lms.organization.mapper;

import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.model.Organization;
import org.springframework.stereotype.Component;

@Component
public class OrganizationMapper {
    public OrganizationResponse ToResponse(
            Organization organization
    ) {

        return OrganizationResponse.builder()
                .id(organization.getId())
                .name(organization.getName())
                .description(organization.getDescription())
                .image(organization.getImageUrl())
                .visibility(organization.getVisibility())
                .ownerName(
                        organization.getOwner().getName()
                )
                .build();
    }
}
