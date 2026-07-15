package app.lms.gamification.repository;

import app.lms.gamification.model.UserActivityDay;
import app.lms.gamification.repository.projection.ScoreboardRow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface UserActivityDayRepository extends JpaRepository<UserActivityDay, Long> {

    Optional<UserActivityDay> findByUserIdAndActivityDate(
            Long userId,
            LocalDate activityDate
    );

    List<UserActivityDay> findAllByUserIdAndActivityDateBetweenOrderByActivityDateAsc(
            Long userId,
            LocalDate from,
            LocalDate to
    );

    List<UserActivityDay> findAllByUserIdOrderByActivityDateAsc(
            Long userId
    );

    @Query("""
            SELECT
                user.id AS userId,
                user.name AS name,
                user.picture AS picture,
                SUM(activityDay.xpEarned) AS periodXp,
                level.levelNumber AS levelNumber,
                level.title AS levelTitle
            FROM UserActivityDay activityDay
            JOIN activityDay.user user
            LEFT JOIN UserProgress progress ON progress.user = user
            LEFT JOIN progress.currentLevel level
            WHERE activityDay.activityDate BETWEEN :from AND :to
            GROUP BY
                user.id,
                user.name,
                user.picture,
                level.levelNumber,
                level.title
            ORDER BY
                SUM(activityDay.xpEarned) DESC,
                user.id ASC
            """)
    List<ScoreboardRow> findScoreboardRows(
            @Param("from") LocalDate from,
            @Param("to") LocalDate to
    );
}
