package app.lms.media.service;

import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.mapper.CourseMediaMapper;
import app.lms.media.model.CourseMedia;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MobileCourseMediaService {

    private final CourseMediaAccessService courseMediaAccessService;
    private final CourseMediaMapper courseMediaMapper;

    public CourseMediaResponse getById(
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                courseMediaAccessService
                        .getAccessibleMedia(
                                organizationId,
                                courseId,
                                mediaId,
                                user
                        );

        return courseMediaMapper.toResponse(media);
    }
}
