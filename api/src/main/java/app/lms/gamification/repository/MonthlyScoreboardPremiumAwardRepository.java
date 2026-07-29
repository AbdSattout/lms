package app.lms.gamification.repository;

import app.lms.gamification.model.MonthlyScoreboardPremiumAward;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.Optional;

public interface MonthlyScoreboardPremiumAwardRepository
        extends JpaRepository<MonthlyScoreboardPremiumAward, Long> {

    Optional<MonthlyScoreboardPremiumAward>
    findByPeriodFromAndPeriodToAndRank(
            LocalDate periodFrom,
            LocalDate periodTo,
            Integer rank
    );
}
