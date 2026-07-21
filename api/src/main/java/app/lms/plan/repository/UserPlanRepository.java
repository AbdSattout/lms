package app.lms.plan.repository;

import app.lms.plan.model.UserPlan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserPlanRepository extends JpaRepository<UserPlan, Long> {

    Optional<UserPlan> findByUserId(
            Long userId
    );

    boolean existsByUserId(
            Long userId
    );
}
