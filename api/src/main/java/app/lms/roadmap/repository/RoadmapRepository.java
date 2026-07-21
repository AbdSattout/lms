package app.lms.roadmap.repository;

import app.lms.roadmap.model.Roadmap;
import app.lms.course.enums.CourseStatus;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface RoadmapRepository extends JpaRepository<Roadmap, Long> {

    Optional<Roadmap> findByIdAndOrganizationId(
            Long roadmapId,
            Long organizationId
    );

    Page<Roadmap> findAllByOrganizationIdOrderByCreatedAtDesc(
            Long organizationId,
            Pageable pageable
    );

    Page<Roadmap> findAllByOrderByCreatedAtDesc(
            Pageable pageable
    );

    @Query("""
            select distinct roadmap
            from Roadmap roadmap
            join roadmap.items item
            where item.course.id = :courseId
            """)
    List<Roadmap> findAllByCourseId(
            @Param("courseId") Long courseId
    );

    @Query("""
            select count(item)
            from RoadmapItem item
            where item.roadmap.id = :roadmapId
            and item.course.status = :courseStatus
            """)
    long countCoursesByStatus(
            @Param("roadmapId") Long roadmapId,
            @Param("courseStatus") CourseStatus courseStatus
    );

    @Query("""
            select count(item)
            from RoadmapItem item
            where item.roadmap.id = :roadmapId
            and item.course.status = :courseStatus
            and not exists (
                select enrollment.id
                from CourseEnrollment enrollment
                where enrollment.course.id = item.course.id
                and enrollment.user.id = :userId
                and enrollment.status = :enrollmentStatus
            )
            """)
    long countIncompleteCoursesForUser(
            @Param("roadmapId") Long roadmapId,
            @Param("userId") Long userId,
            @Param("courseStatus") CourseStatus courseStatus,
            @Param("enrollmentStatus") EnrollmentStatus enrollmentStatus
    );

    void deleteByOrganizationId(
            Long organizationId
    );
}
