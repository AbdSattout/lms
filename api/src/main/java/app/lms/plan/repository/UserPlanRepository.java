package app.lms.plan.repository;

import app.lms.plan.model.UserPlan;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserPlanRepository extends JpaRepository<UserPlan, Long> {

    Optional<UserPlan> findByUserId(
            Long userId
    );

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query(
            """
            select userPlan
            from UserPlan userPlan
            where userPlan.user.id = :userId
            """
    )
    Optional<UserPlan> findByUserIdForUpdate(
            @Param("userId") Long userId
    );

    boolean existsByUserId(
            Long userId
    );
}
