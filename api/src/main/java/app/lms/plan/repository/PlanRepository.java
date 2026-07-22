package app.lms.plan.repository;

import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PlanRepository extends JpaRepository<Plan, Long> {

    Optional<Plan> findByCode(
            PlanCode code
    );

    boolean existsByCode(
            PlanCode code
    );
}
