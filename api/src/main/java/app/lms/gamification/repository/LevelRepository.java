package app.lms.gamification.repository;

import app.lms.gamification.model.Level;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LevelRepository extends JpaRepository<Level, Long> {

    Optional<Level> findByLevelNumber(
            Integer levelNumber
    );

    Optional<Level> findTopByRequiredXpLessThanEqualOrderByRequiredXpDesc(
            Integer totalXp
    );

    Optional<Level> findTopByRequiredXpGreaterThanOrderByRequiredXpAsc(
            Integer totalXp
    );

    List<Level> findAllByRequiredXpLessThanEqualOrderByRequiredXpAsc(
            Integer totalXp
    );

    boolean existsByLevelNumber(
            Integer levelNumber
    );
}
