package app.lms.plan.service;

import app.lms.common.exception.NotFoundException;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.UserPlan;
import app.lms.plan.repository.PlanRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserPlanExpirationService {

    private final PlanRepository planRepository;

    @Transactional
    public void expireIfNeeded(
            UserPlan userPlan
    ) {

        if (!isPremiumExpired(userPlan)) {
            return;
        }

        downgradeToFree(userPlan);
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

    private void downgradeToFree(
            UserPlan userPlan
    ) {

        userPlan.setPlan(
                planRepository
                        .findByCode(PlanCode.FREE)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Free plan not found"
                                )
                        )
        );
        userPlan.setStartedAt(
                LocalDateTime.now()
        );
        userPlan.setExpiresAt(null);
        userPlan.setCanceledAt(null);
    }
}
