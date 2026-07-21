package app.lms.courceEnrollment.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.dto.CourseResponse;
import app.lms.course.mapper.CourseMapper;
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

    public CourseEnrollment getEnrollment(
            Long courseId,
            User user
    ) {

        return enrollmentRepository
                .findByUserIdAndCourseId(
                        user.getId(),
                        courseId
                )
                .orElseThrow(() ->
                        new ForbiddenException(
                                "You are not enrolled in this course"
                        )
                );
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
                .findAllByUserIdAndStatus(
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
