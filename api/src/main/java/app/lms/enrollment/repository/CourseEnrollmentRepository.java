package app.lms.enrollment.repository;

import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;


public interface CourseEnrollmentRepository
        extends JpaRepository<CourseEnrollment, Long> {



    List<CourseEnrollment> findAllByUserIdAndStatusInAndCourseIdIn(
            Long userId,
            List<EnrollmentStatus> statuses,
            List<Long> courseIds
    );




    @Query("""
            select count(enrollment)
            from CourseEnrollment enrollment
            where enrollment.user.id = :userId
            and enrollment.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id =
                        enrollment.course.organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id =
                        enrollment.course.organization.id
                and ban.user.id = :userId
            )
            """)
    long countByUserIdAndStatusAndCourseOrganizationVisible(
            @Param("userId") Long userId,
            @Param("status") EnrollmentStatus status
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

}
