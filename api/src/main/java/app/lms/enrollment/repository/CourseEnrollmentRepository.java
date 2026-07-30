package app.lms.enrollment.repository;

import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
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

    Page<CourseEnrollment> findAllByUserIdAndStatus(
            Long userId,
            EnrollmentStatus status,
            Pageable pageable
    );

    List<CourseEnrollment> findAllByUserIdAndStatusAndCourseIdIn(
            Long userId,
            EnrollmentStatus status,
            List<Long> courseIds
    );

    List<CourseEnrollment> findAllByUserIdAndStatusInAndCourseIdIn(
            Long userId,
            List<EnrollmentStatus> statuses,
            List<Long> courseIds
    );

    List<CourseEnrollment>
    findAllByCourseId(Long courseId);
    boolean existsByCourseIdAndUserId(
            Long courseId,
            Long userId
    );

    long countByUserIdAndStatus(
            Long userId,
            EnrollmentStatus status
    );

    long countByCourseId(Long courseId);

    long countByCourseIdAndStatus(
            Long courseId,
            EnrollmentStatus status
    );

    boolean existsByUserIdAndCourseOrganizationIdAndStatus(
            Long userId,
            Long organizationId,
            EnrollmentStatus status
    );

    List<CourseEnrollment> findByUserIdAndCourseOrganizationIdAndStatus(
            Long userId,
            Long organizationId,
            EnrollmentStatus status
    );

}
