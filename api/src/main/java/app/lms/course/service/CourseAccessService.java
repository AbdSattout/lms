package app.lms.course.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseAccessService {

    private final CourseRepository courseRepository;
    private final OrganizationMemberAccessService
            organizationMemberAccessService;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

    public Course getById(
            Long courseId
    ) {

        return courseRepository.findById(courseId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Course not found"
                        )
                );
    }

    private Course getBySlug(
            String slug
    ) {

        return courseRepository
                .findBySlug(slug)
                .orElseThrow(
                        () -> new NotFoundException(
                                "Course not found"
                        )
                );
    }
    public Course getPublishedBySlug(
            String slug
    ) {

        Course course =
                getBySlug(slug);

        if (
                course.getStatus()
                        != CourseStatus.PUBLISHED
        ) {
            throw new NotFoundException(
                    "Course not found"
            );
        }

        return course;
    }
    public Course getEnrolledCourse(
            Long courseId,
            User user
    ) {

        Course course =
                getAccessibleCourse(
                        courseId,
                        user
                );

        boolean manager =
                organizationMemberAccessService
                        .isManager(
                                course.getOrganization().getId(),
                                user.getId()
                        );

        if (!manager) {

            courseEnrollmentAccessService
                    .validateEnrolled(
                            courseId,
                            user.getId()
                    );
        }

        return course;
    }


    public Course getAccessibleCourse(
            Long courseId,
            User user
    ) {

        Course course =
                getById(
                        courseId
                );

        if (
                course.getStatus()
                        == CourseStatus.PUBLISHED
        ) {

            organizationMemberAccessService
                    .getMember(
                            course.getOrganization().getId(),
                            user.getId()
                    );

            return course;
        }

        organizationMemberAccessService
                .validateManager(
                        course.getOrganization().getId(),
                        user.getId()
                );

        return course;
    }

    public Course getManageableCourse(
            Long courseId,
            User user
    ) {

        Course course =
                getById(courseId);

        organizationMemberAccessService
                .validateManager(
                        course.getOrganization().getId(),
                        user.getId()
                );

        return course;
    }
    public Course getManageableCourse(
            String slug,
            User user
    ) {

        Course course =
                getBySlug(slug);

        organizationMemberAccessService
                .validateManager(
                        course.getOrganization().getId(),
                        user.getId()
                );

        return course;
    }

    public Course getEditableCourse(
            Long courseId,
            User user
    ) {

        Course course =
                getById(courseId);

        organizationMemberAccessService
                .validateManager(
                        course.getOrganization().getId(),
                        user.getId()
                );

        validateDraft(course);

        return course;
    }
    private void validateDraft(
            Course course
    ) {

        if (course.getStatus()
                == CourseStatus.PUBLISHED) {

            throw new ConflictException(
                    "Published course cannot be modified"
            );
        }
    }
}