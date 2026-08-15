package app.lms.badge.repository;

import app.lms.badge.model.UserBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface UserBadgeRepository extends JpaRepository<UserBadge, Long> {

    List<UserBadge> findAllByUserIdOrderByBadgeSortOrderAscEarnedAtAsc(
            Long userId
    );

    List<UserBadge> findAllByUserIdAndBadgeActiveTrueOrderByBadgeSortOrderAscEarnedAtAsc(
            Long userId
    );

    List<UserBadge> findAllByUserIdAndBadgeCodeInAndBadgeActiveTrueOrderByBadgeSortOrderAscEarnedAtAsc(
            Long userId,
            Collection<String> codes
    );

    @Modifying
    @Query(
            value = """
                    INSERT INTO user_badges (
                        user_id,
                        badge_id,
                        earned_at,
                        created_at,
                        updated_at
                    )
                    SELECT :userId,
                           badge.id,
                           CURRENT_TIMESTAMP,
                           CURRENT_TIMESTAMP,
                           CURRENT_TIMESTAMP
                    FROM badges badge
                    WHERE badge.code IN (:codes)
                      AND badge.active = true
                    ON CONFLICT (user_id, badge_id) DO NOTHING
                    """,
            nativeQuery = true
    )
    void insertMissingActiveBadges(
            @Param("userId")
            Long userId,

            @Param("codes")
            Collection<String> codes
    );
}
