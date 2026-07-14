package app.lms.gamification.repository;

import app.lms.gamification.model.UserProgress;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserProgressRepository
        extends JpaRepository<UserProgress, Long> {

    Optional<UserProgress> findByUserId(
            Long userId
    );

    boolean existsByUserId(
            Long userId
    );

    List<UserProgress> findAllByCurrentLevelIsNull();
}
