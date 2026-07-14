package app.lms.media.mapper;

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
                media.getPost().getId()
        );
    }
}
