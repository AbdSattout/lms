package app.lms.course.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.CourseBan.repository.CourseBanRepository;
import app.lms.course.CourseBan.repository.CourseModerationRepository;
import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
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
    private final CourseModerationRepository courseModerationRepository;
    private final CourseBanRepository courseBanRepository;

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
            Long organizationId,
            String slug
    ) {

        return courseRepository
                .findByOrganizationIdAndSlug(
                        organizationId,
                        slug
                )
                .orElseThrow(
                        () -> new NotFoundException(
                                "Course not found"
                        )
                );
    }
    public Course getPublishedBySlug(
            Long organizationId,
            String slug
    ) {

        Course course =
                getBySlug(
                        organizationId,
                        slug
                );

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
                            user
                    );
        }

        return course;
    }

    public Course getEnrolledCourse(
            Long organizationId,
            String slug,
            User user
    ) {

        Course course =
                getAccessibleCourse(
                        organizationId,
                        slug,
                        user
                );

        boolean manager =
                organizationMemberAccessService
                        .isManager(
                                organizationId,
                                user.getId()
                        );

        if (!manager) {

            courseEnrollmentAccessService
                    .validateEnrolled(
                            course.getId(),
                            user
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

    public Course getAccessibleCourse(
            Long organizationId,
            String slug,
            User user
    ) {

        Course course =
                getBySlug(
                        organizationId,
                        slug
                );

        if (
                course.getStatus()
                        == CourseStatus.PUBLISHED
        ) {

            organizationMemberAccessService
                    .getMember(
                            organizationId,
                            user.getId()
                    );

            return course;
        }

        organizationMemberAccessService
                .validateManager(
                        organizationId,
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
            Long organizationId,
            String slug,
            User user
    ) {

        Course course =
                getBySlug(
                        organizationId,
                        slug
                );

        organizationMemberAccessService
                .validateManager(
                        organizationId,
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

    public Course getEditableCourse(
            Long organizationId,
            String slug,
            User user
    ) {

        Course course =
                getBySlug(
                        organizationId,
                        slug
                );

        organizationMemberAccessService
                .validateManager(
                        organizationId,
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
    public void validateNotBanned(
            Course course
    ) {

        if (
                courseModerationRepository.existsByCourseId(
                        course.getId()
                )
        ) {

            throw new ForbiddenException(
                    "This course has been banned."
            );

        }

    }

    public void validateUserNotBannedFromCourse(
            Course course,
            User user
    ) {

        if (
                courseBanRepository.existsByCourseIdAndUserId(
                        course.getId(),
                        user.getId()
                )
        ) {

            throw new ForbiddenException(
                    "This user has been banned from this course"
            );

        }

    }
}
