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
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserPlanService {

    private final PlanRepository planRepository;
    private final UserPlanRepository userPlanRepository;
    private final UserPlanExpirationService userPlanExpirationService;

    @Transactional
    public Plan getOrCreateCurrentPlan(
            User user
    ) {

        return getOrCreateCurrentUserPlan(
                user,
                false
        )
                .getPlan();
    }

    @Transactional
    public Plan getOrCreateCurrentPlanForUpdate(
            User user
    ) {

        return getOrCreateCurrentUserPlan(
                user,
                true
        )
                .getPlan();
    }

    private UserPlan getOrCreateCurrentUserPlan(
            User user,
            boolean lock
    ) {

        UserPlan userPlan =
                currentUserPlan(
                        user,
                        lock
                )
                        .orElseGet(() ->
                                createFreeUserPlan(user)
                        );

        userPlanExpirationService.expireIfNeeded(userPlan);

        return userPlan;
    }

    private Optional<UserPlan> currentUserPlan(
            User user,
            boolean lock
    ) {

        if (lock) {
            return userPlanRepository.findByUserIdForUpdate(
                    user.getId()
            );
        }

        return userPlanRepository.findByUserId(
                user.getId()
        );
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
