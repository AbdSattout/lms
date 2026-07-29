package app.lms.plan.repository;

import app.lms.plan.model.UserPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface UserPlanRepository extends JpaRepository<UserPlan, Long> {

    Optional<UserPlan> findByUserId(
            Long userId
    );

    @Query(
            value = """
                    select *
                    from user_plans
                    where user_id = :userId
                    for update
                    """,
            nativeQuery = true
    )
    Optional<UserPlan> findByUserIdForUpdate(
            @Param("userId") Long userId
    );

    boolean existsByUserId(
            Long userId
    );

    @Query("""
            select userPlan
            from UserPlan userPlan
            join fetch userPlan.user
            join fetch userPlan.plan plan
            where plan.code = app.lms.plan.enums.PlanCode.PREMIUM
              and userPlan.expiresAt is not null
              and userPlan.expiresAt <= :now
            """)
    List<UserPlan> findExpiredPremiumPlans(
            @Param("now") LocalDateTime now
    );
}
