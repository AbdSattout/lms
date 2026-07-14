package app.lms.media.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.dto.PostMediaResponse;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.model.PostMedia;
import org.springframework.stereotype.Component;

@Component
public class PostMediaMapper {

    public PostMediaResponse toResponse(
            PostMedia media
    ) {

        OrganizationMedia organizationMedia =
                media.getOrganizationMedia();

        return new PostMediaResponse(
                media.getId(),
                organizationMedia != null
                        ? organizationMedia.getName()
                        : null,
                organizationMedia != null
                        ? organizationMedia.getUrl()
                        : null,
                organizationMedia != null
                        ? organizationMedia.getType()
                        : null,
                media.getOrganization().getId(),
                organizationMedia != null
                        ? organizationMedia.getId()
                        : null,
                organizationMedia != null
                        ? organizationMedia.getSizeBytes()
                        : null,
                BaseEntityResponse.from(media)
        );
    }
}
