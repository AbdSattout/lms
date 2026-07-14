package app.lms.media.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.dto.OrganizationMediaResponse;
import app.lms.media.model.OrganizationMedia;
import org.springframework.stereotype.Component;

@Component
public class OrganizationMediaMapper {

    public OrganizationMediaResponse toResponse(
            OrganizationMedia media
    ) {

        return new OrganizationMediaResponse(
                media.getId(),
                media.getName(),
                media.getUrl(),
                media.getType(),
                media.getSizeBytes(),
                media.getOrganization().getId(),
                BaseEntityResponse.from(media)
        );
    }
}
