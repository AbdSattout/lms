package app.lms.courceEnrollment.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentAccessService {

    private final CourseEnrollmentRepository enrollmentRepository;

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
}