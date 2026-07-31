package app.lms.course.CourseBan.repository;

import app.lms.course.CourseBan.model.CourseBan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CourseBanRepository
        extends JpaRepository<CourseBan, Long> {

    boolean existsByCourseIdAndUserId(
            Long courseId,
            Long userId
    );
    Optional<CourseBan> findByCourseIdAndUserId(
            Long courseId,
            Long userId
    );



}

