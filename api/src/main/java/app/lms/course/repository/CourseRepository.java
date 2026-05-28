package app.lms.course.repository;

import app.lms.course.model.Course;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    List<Course>
    findAllByOrganizationId(Long organizationId);
}
