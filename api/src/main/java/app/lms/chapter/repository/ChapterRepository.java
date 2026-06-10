package app.lms.chapter.repository;

import app.lms.chapter.model.Chapter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ChapterRepository
        extends JpaRepository<Chapter, Long> {

    List<Chapter>
    findAllByCourseIdOrderByPositionAsc(
            Long courseId
    );
    @Query("""
       select max(c.position)
       from Chapter c
       where c.course.id = :courseId
       """)
    Optional<Integer> findMaxPositionByCourseId(
            Long courseId
    );
    List<Chapter> findAllByCourseId(
            Long courseId
    );

    Optional<Chapter>
    findFirstByCourseIdAndPositionGreaterThanOrderByPositionAsc(
            Long courseId,
            Integer position
    );
}
