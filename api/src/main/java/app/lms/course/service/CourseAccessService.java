package app.lms.course.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
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