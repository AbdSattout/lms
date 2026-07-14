package app.lms.media.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.model.CourseMedia;
import app.lms.media.model.OrganizationMedia;
import org.springframework.stereotype.Component;

@Component
public class CourseMediaMapper {

    public CourseMediaResponse toResponse(
            CourseMedia media
    ) {

        OrganizationMedia organizationMedia =
                media.getOrganizationMedia();

        return new CourseMediaResponse(
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
                media.getCourse().getId(),
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
