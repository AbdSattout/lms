package app.lms.organization.repository;

import app.lms.organization.model.Block;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface BlockRepository
        extends JpaRepository<Block, Long> {

    List<Block>
    findAllByLessonIdOrderByPositionAsc(
            Long lessonId
    );

    @Query("""
    SELECT COUNT(b)
    FROM Block b
    WHERE b.lesson.chapter.course.id = :courseId
    """)
    long countByCourseId(
            @Param("courseId")
            Long courseId
    );
}
