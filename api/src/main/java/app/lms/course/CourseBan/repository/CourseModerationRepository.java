package app.lms.course.CourseBan.repository;

import app.lms.course.CourseBan.model.CourseBan;
import app.lms.course.CourseBan.model.CourseModeration;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CourseModerationRepository
        extends JpaRepository<CourseModeration, Long> {

    boolean existsByCourseId(
            Long courseId
    );

    Optional<CourseModeration> findByCourseId(
            Long courseId
    );
}
