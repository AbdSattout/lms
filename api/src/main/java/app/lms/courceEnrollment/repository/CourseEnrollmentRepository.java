package app.lms.courceEnrollment.repository;

import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CourseEnrollmentRepository
        extends JpaRepository<CourseEnrollment, Long> {

    boolean existsByUserIdAndCourseId(
            Long userId,
            Long courseId
    );

    Optional<CourseEnrollment>
    findByUserIdAndCourseId(
            Long userId,
            Long courseId
    );

    List<CourseEnrollment>
    findAllByUserIdAndStatus(Long userId , EnrollmentStatus status);

    List<CourseEnrollment>
    findAllByCourseId(Long courseId);
    boolean existsByCourseIdAndUserId(
            Long courseId,
            Long userId
    );
}
