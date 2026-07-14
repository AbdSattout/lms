package app.lms.block.repository;

import app.lms.block.model.Block;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

    @Repository
    public interface BlockRepository
            extends JpaRepository<Block, Long> {

        
        List<Block> findAllByLessonId(
                Long lessonId
        );

        List<Block> findAllByLessonIdOrderByPositionAsc(
                Long lessonId
        );

        @Query("""
        SELECT MAX(b.position)
        FROM Block b
        WHERE b.lesson.id = :lessonId
       """)
        Optional<Integer> findMaxPositionByLessonId(
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

        Optional<Block>
        findFirstByLessonIdAndPositionGreaterThanOrderByPositionAsc(
                Long lessonId,
                Integer position
        );

        Optional<Block>
        findFirstByLessonIdOrderByPositionAsc(
                Long lessonId
        );

        long countByLessonChapterCourseId(
                Long courseId
        );

        long countByLessonId(
                Long lessonId
        );

        long countByLessonChapterId(
                Long chapterId
        );

        boolean existsByQuestionId(
                Long questionId
        );
}
