package app.lms.media.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.model.CourseMedia;
import org.springframework.stereotype.Component;

@Component
public class CourseMediaMapper {

    public CourseMediaResponse toResponse(
            CourseMedia media
    ) {

        return new CourseMediaResponse(
                media.getId(),
                media.getName(),
                media.getUrl(),
                media.getType(),
                media.getCourse().getId(),
                BaseEntityResponse.from(media)
        );
    }
}
