package app.lms.plan.service;

import app.lms.common.exception.NotFoundException;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.UserPlan;
import app.lms.plan.repository.PlanRepository;
import app.lms.plan.repository.UserPlanRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class UserPlanExpirationService {

    private final PlanRepository planRepository;
    private final UserPlanRepository userPlanRepository;
    private final PlanLimitCacheService planLimitCacheService;

    @Scheduled(
            fixedDelayString = "${app.plans.expiration-scheduler.fixed-delay-ms:3600000}",
            initialDelayString = "${app.plans.expiration-scheduler.initial-delay-ms:60000}"
    )
    @Transactional
    public void expireExpiredPremiumPlans() {

        List<UserPlan> expiredPremiumPlans =
                userPlanRepository.findExpiredPremiumPlans(
                        LocalDateTime.now()
                );

        if (expiredPremiumPlans.isEmpty()) {
            return;
        }

        expiredPremiumPlans.forEach(this::downgradeToFree);

        log.info(
                "Expired {} premium user plan(s)",
                expiredPremiumPlans.size()
        );
    }

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

        planLimitCacheService.cache(userPlan);
    }
}
