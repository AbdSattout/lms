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
            Long courseId,
            Long mediaId,
            User user
    ) {

        courseAccessService
                .getEditableCourse(
                        courseId,
                        user
                );

        return getByIdAndCourseId(
                mediaId,
                courseId
        );
    }

    public CourseMedia getAccessibleMedia(
            Long courseId,
            Long mediaId,
            User user
    ) {

        courseAccessService
                .getEnrolledCourse(
                        courseId,
                        user
                );

        return getByIdAndCourseId(
                mediaId,
                courseId
        );
    }

    private CourseMedia getByIdAndCourseId(
            Long mediaId,
            Long courseId
    ) {

        return courseMediaRepository
                .findByIdAndCourseId(
                        mediaId,
                        courseId
                )
                .orElseThrow(
                        () -> new NotFoundException(
                                "Media not found"
                        )
                );
    }
}
