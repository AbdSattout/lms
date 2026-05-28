package app.lms.organization.repository;

import app.lms.organization.model.Progress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProgressRepository
        extends JpaRepository<Progress, Long> {

    Optional<Progress>
    findByUserIdAndBlockId(
            Long userId,
            Long blockId
    );

    List<Progress>
    findAllByUserId(Long userId);

    List<Progress>
    findAllByBlockId(Long blockId);

    long countByUserIdAndCompletedTrue(
            Long userId
    );

    long countByUserIdAndCorrectTrue(
            Long userId
    );

    @Query("""
    SELECT COUNT(p)
    FROM Progress p
    WHERE p.user.id = :userId
    AND p.completed = true
    AND p.block.lesson.chapter.course.id = :courseId
    """)
    long countCompletedBlocksByCourse(

            @Param("courseId")
            Long courseId,

            @Param("userId")
            Long userId
    );
}
