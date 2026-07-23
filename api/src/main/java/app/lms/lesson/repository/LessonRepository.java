package app.lms.lesson.repository;

import app.lms.lesson.model.Lesson;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface LessonRepository
        extends JpaRepository<Lesson, Long> {

    List<Lesson>
    findAllByChapterIdOrderByPositionAsc(
            Long chapterId
    );

    List<Lesson>
    findAllByChapterId(
            Long chapterId
    );

    @Query("""
        select max(l.position)
        from Lesson l
        where l.chapter.id = :chapterId
    """)
    Optional<Integer>
    findMaxPositionByChapterId(
            Long chapterId
    );

    Optional<Lesson>
    findFirstByChapterIdAndPositionGreaterThanOrderByPositionAsc(
            Long chapterId,
            Integer position
    );

    Optional<Lesson>
    findFirstByChapterIdOrderByPositionAsc(
            Long chapterId
    );

    @Query("""
select count(l)
from Lesson l
where l.chapter.course.id = :courseId
""")
    long countByCourseId(Long courseId);
}
