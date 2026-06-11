package app.lms.progress.repository;

import app.lms.progress.model.BlockProgress;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

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


}