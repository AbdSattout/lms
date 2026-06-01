package app.lms.course.repository;

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

    boolean existsBySlug(String slug);

    Optional<Course> findBySlug(String slug);
}
