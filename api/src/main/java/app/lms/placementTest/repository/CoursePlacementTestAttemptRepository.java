package app.lms.placementTest.repository;

import app.lms.placementTest.model.CoursePlacementTestAttempt;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CoursePlacementTestAttemptRepository
        extends JpaRepository<CoursePlacementTestAttempt, Long> {

    Optional<CoursePlacementTestAttempt> findByCourseIdAndUserId(
            Long courseId,
            Long userId
    );
}
