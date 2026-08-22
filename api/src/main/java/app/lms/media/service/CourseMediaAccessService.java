package app.lms.media.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
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

    public CourseMedia getManageableMedia(
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        Course course =
                courseAccessService.getManageableCourse(
                        courseId,
                        user
                );

        if (
                !course.getOrganization()
                        .getId()
                        .equals(organizationId)
        ) {
            throw new NotFoundException(
                    "Course not found"
            );
        }

        return courseMediaRepository
                .findByIdAndCourseId(
                        mediaId,
                        courseId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Media not found"
                        )
                );
    }
    public CourseMedia getEditableMedia(
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        validateCourseOrganization(
                course,
                organizationId
        );

        return getByIdAndCourseId(
                mediaId,
                course.getId()
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
            Long organizationId,
            Long courseId,
            Long mediaId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEnrolledCourse(
                                courseId,
                                user
                        );

        validateCourseOrganization(
                course,
                organizationId
        );

        return getByIdAndCourseId(
                mediaId,
                course.getId()
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

    private void validateCourseOrganization(
            Course course,
            Long organizationId
    ) {

        if (
                !course.getOrganization()
                        .getId()
                        .equals(organizationId)
        ) {
            throw new NotFoundException(
                    "Course not found"
            );
        }
    }
}
