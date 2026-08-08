package app.lms.enrollment.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.course.dto.CourseResponse;
import app.lms.course.mapper.CourseMapper;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentAccessService {

    private final CourseEnrollmentRepository enrollmentRepository;
    private final CourseMapper courseMapper;
    private final OrganizationAccessService organizationAccessService;

    public CourseEnrollment getEnrollment(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                enrollmentRepository
                .findByUserIdAndCourseId(
                        user.getId(),
                        courseId
                )
                .orElseThrow(() ->
                        new ForbiddenException(
                                "You are not enrolled in this course"
                        )
                );

        if (enrollment.getStatus() == EnrollmentStatus.DROPPED) {
            throw new ForbiddenException(
                    "You are not enrolled in this course"
            );
        }

        organizationAccessService.validateNotBanned(
                enrollment.getCourse()
                        .getOrganization()
        );

        organizationAccessService
                .validateUserNotBannedFromOrg(
                        enrollment.getCourse()
                                .getOrganization(),
                        user
                );

        return enrollment;
    }

    public void validateEnrolled(
            Long courseId,
            User user
    ) {

        getEnrollment(
                courseId,
                user
        );
    }
    public Page<CourseResponse> myCourses(
            Pageable pageable,
            User user
    ) {

        return enrollmentRepository
                .findAllByUserIdAndStatusAndCourseOrganizationNotBanned(
                        user.getId(),
                        EnrollmentStatus.ACTIVE,
                        pageable
                )
                .map(enrollment ->
                        courseMapper.toResponse(
                                enrollment.getCourse(),
                                enrollment
                        )
                );

    }
}
