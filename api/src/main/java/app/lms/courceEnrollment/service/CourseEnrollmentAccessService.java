package app.lms.courceEnrollment.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentAccessService {

    private final CourseEnrollmentRepository
            courseEnrollmentRepository;

    public void validateEnrolled(
            Long courseId,
            Long userId
    ) {

        boolean enrolled =
                courseEnrollmentRepository
                        .existsByCourseIdAndUserId(
                                courseId,
                                userId
                        );

        if (!enrolled) {
            throw new ForbiddenException(
                    "You are not enrolled in this course"
            );
        }
    }
}
