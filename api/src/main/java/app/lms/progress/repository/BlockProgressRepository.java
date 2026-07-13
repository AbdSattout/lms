package app.lms.progress.repository;

import app.lms.progress.model.BlockProgress;
import app.lms.question.model.Question;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface BlockProgressRepository
        extends JpaRepository<BlockProgress, Long> {

    Optional<BlockProgress>
    findByUserIdAndBlockId(
            Long userId,
            Long blockId
    );

    long countByUserIdAndBlockLessonChapterCourseIdAndCompletedTrue(
            Long userId,
            Long courseId
    );



    @Query("""
            select distinct q
            from BlockProgress bp
            join bp.block b
            join b.question q
            where bp.user.id = :userId
            and b.lesson.chapter.course.id = :courseId
            and bp.completed = true
            """)
    List<Question> findCompletedQuestionsByUserAndCourse(
            Long userId,
            Long courseId
    );


}