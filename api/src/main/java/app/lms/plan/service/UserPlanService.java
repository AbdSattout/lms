package app.lms.plan.service;

import app.lms.common.exception.NotFoundException;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import app.lms.plan.model.UserPlan;
import app.lms.plan.repository.PlanRepository;
import app.lms.plan.repository.UserPlanRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserPlanService {

    private final PlanRepository planRepository;
    private final UserPlanRepository userPlanRepository;

    @Transactional
    public Plan getOrCreateCurrentPlan(
            User user
    ) {

        return getOrCreateCurrentUserPlan(user)
                .getPlan();
    }

    private UserPlan getOrCreateCurrentUserPlan(
            User user
    ) {

        UserPlan userPlan =
                userPlanRepository
                        .findByUserId(
                                user.getId()
                        )
                        .orElseGet(() ->
                                createFreeUserPlan(user)
                        );

        if (isPremiumExpired(userPlan)) {
            downgradeToFree(userPlan);
        }

        return userPlan;
    }

    private boolean isPremiumExpired(
            UserPlan userPlan
    ) {

        return isPremiumPlan(userPlan) &&
                userPlan.getExpiresAt() != null &&
                userPlan.getExpiresAt()
                        .isBefore(LocalDateTime.now());
    }

    private boolean isPremiumPlan(
            UserPlan userPlan
    ) {

        return userPlan.getPlan()
                .getCode() == PlanCode.PREMIUM;
    }

    private UserPlan createFreeUserPlan(
            User user
    ) {

        return userPlanRepository.save(
                UserPlan.builder()
                        .user(user)
                        .plan(freePlan())
                        .startedAt(LocalDateTime.now())
                        .build()
        );
    }

    private void downgradeToFree(
            UserPlan userPlan
    ) {

        userPlan.setPlan(
                freePlan()
        );
        userPlan.setStartedAt(
                LocalDateTime.now()
        );
        userPlan.setExpiresAt(null);
        userPlan.setCanceledAt(null);
    }

    private Plan freePlan() {

        return planRepository
                .findByCode(PlanCode.FREE)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Free plan not found"
                        )
                );
    }
}
