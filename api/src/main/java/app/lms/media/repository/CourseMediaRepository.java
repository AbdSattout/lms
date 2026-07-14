package app.lms.media.repository;

import app.lms.media.model.CourseMedia;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CourseMediaRepository extends JpaRepository<CourseMedia, Long> {

    Page<CourseMedia> findAllByCourseIdOrderByCreatedAtDesc(
            Long courseId,
            Pageable pageable
    );

    Optional<CourseMedia> findByIdAndCourseId(
            Long mediaId,
            Long courseId
    );

    boolean existsByCourseIdAndNameIgnoreCase(
            Long courseId,
            String name
    );

    boolean existsByCourseIdAndNameIgnoreCaseAndIdNot(
            Long courseId,
            String name,
            Long mediaId
    );
}
