package app.lms.media.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.dto.PostMediaResponse;
import app.lms.media.model.PostMedia;
import org.springframework.stereotype.Component;

@Component
public class PostMediaMapper {

    public PostMediaResponse toResponse(
            PostMedia media
    ) {

        return new PostMediaResponse(
                media.getId(),
                media.getName(),
                media.getUrl(),
                media.getType(),
                media.getOrganization().getId(),
                media.getOrganizationMedia() != null
                        ? media.getOrganizationMedia().getId()
                        : null,
                media.getOrganizationMedia() != null
                        ? media.getOrganizationMedia().getSizeBytes()
                        : null,
                BaseEntityResponse.from(media)
        );
    }
}
