package app.lms.media.service;

import app.lms.media.dto.PostMediaResponse;
import app.lms.media.mapper.PostMediaMapper;
import app.lms.media.model.PostMedia;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MobilePostMediaService {

    private final PostMediaAccessService postMediaAccessService;
    private final PostMediaMapper postMediaMapper;

    public PostMediaResponse getById(
            Long organizationId,
            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getAccessibleMedia(
                                organizationId,
                                mediaId,
                                user
                        );

        return postMediaMapper.toResponse(media);
    }
}
