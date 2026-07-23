package app.lms.billing.service;

import app.lms.common.exception.NotFoundException;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import app.lms.plan.model.UserPlan;
import app.lms.plan.repository.PlanRepository;
import app.lms.plan.repository.UserPlanRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class UserPlanBillingService {

    private final PlanRepository planRepository;
    private final UserPlanRepository userPlanRepository;

    @Transactional
    public void activatePremium(
            User user,
            LocalDateTime startedAt,
            LocalDateTime expiresAt
    ) {

        UserPlan userPlan =
                userPlanRepository
                        .findByUserIdForUpdate(user.getId())
                        .orElseGet(() ->
                                UserPlan.builder()
                                        .user(user)
                                        .build()
                        );

        userPlan.setPlan(
                plan(PlanCode.PREMIUM)
        );
        userPlan.setStartedAt(
                startedAt != null
                        ? startedAt
                        : LocalDateTime.now()
        );
        userPlan.setExpiresAt(expiresAt);
        userPlan.setCanceledAt(null);

        userPlanRepository.save(userPlan);
    }

    @Transactional
    public void downgradeToFree(
            User user
    ) {

        UserPlan userPlan =
                userPlanRepository
                        .findByUserIdForUpdate(user.getId())
                        .orElseGet(() ->
                                UserPlan.builder()
                                        .user(user)
                                        .build()
                        );

        userPlan.setPlan(
                plan(PlanCode.FREE)
        );
        userPlan.setStartedAt(
                LocalDateTime.now()
        );
        userPlan.setExpiresAt(null);
        userPlan.setCanceledAt(null);

        userPlanRepository.save(userPlan);
    }

    private Plan plan(
            PlanCode code
    ) {

        return planRepository
                .findByCode(code)
                .orElseThrow(() ->
                        new NotFoundException(
                                code + " plan not found"
                        )
                );
    }
}
