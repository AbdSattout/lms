package app.lms.course.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.organization.model.Organization;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    Page<Course> findAllByOrganizationId(
            Long organizationId,
            Pageable pageable
    );


    List<Course> findAllByOrganizationId(
            Long organizationId
    );
    Page<Course> findAllByOrganizationIdAndStatus(
            Long organizationId,
            CourseStatus status,
            Pageable pageable
    );

    boolean existsByOrganizationIdAndSlug(
            Long organizationId,
            String slug
    );

    Optional<Course> findByOrganizationIdAndSlug(
            Long organizationId,
            String slug
    );
}
