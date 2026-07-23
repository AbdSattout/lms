package app.lms.plan.repository;

import app.lms.plan.model.UserPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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
}
