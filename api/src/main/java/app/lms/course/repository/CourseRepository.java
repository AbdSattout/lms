package app.lms.course.repository;

import app.lms.course.model.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    Page<Course> findAllByOrganizationId(
            Long organizationId,
            Pageable pageable
    );


    List<Course> findAllByOrganizationId(
            Long organizationId
    );
}
