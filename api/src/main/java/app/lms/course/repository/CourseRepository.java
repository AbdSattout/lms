package app.lms.course.repository;

import app.lms.course.model.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    Page<Course> findByOrganizationId(
            Long organizationId,
            Pageable pageable
    );
}
