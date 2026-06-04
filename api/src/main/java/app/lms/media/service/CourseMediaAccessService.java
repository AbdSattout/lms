package app.lms.media.service;

import app.lms.common.exception.NotFoundException;
import app.lms.media.model.CourseMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseMediaAccessService {

    private final CourseMediaRepository
            courseMediaRepository;

    private final CourseAccessService
            courseAccessService;

    public CourseMedia getById(
            Long mediaId
    ) {

        return courseMediaRepository
                .findById(
                        mediaId
                )
                .orElseThrow(
                        () -> new NotFoundException(
                                "Media not found"
                        )
                );
    }

    public CourseMedia getEditableMedia(
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                getById(mediaId);

        courseAccessService
                .getEditableCourse(
                        media.getCourse().getId(),
                        user
                );

        return media;
    }

    public CourseMedia getAccessibleMedia(
            Long mediaId,
            User user
    ) {

        CourseMedia media =
                getById(mediaId);

        courseAccessService
                .getAccessibleCourse(
                        media.getCourse().getId(),
                        user
                );

        return media;
    }
}