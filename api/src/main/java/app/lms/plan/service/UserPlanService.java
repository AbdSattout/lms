package app.lms.plan.service;

import app.lms.common.exception.NotFoundException;
import app.lms.plan.dto.UserPlanResponse;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.mapper.UserPlanMapper;
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
    private final UserPlanMapper userPlanMapper;

    @Transactional
    public Plan currentPlan(
            User user
    ) {

        return currentUserPlan(user)
                .getPlan();
    }

    @Transactional
    public UserPlanResponse current(
            User user
    ) {

        UserPlan userPlan =
                currentUserPlan(user);

        return userPlanMapper.toResponse(
                userPlan.getPlan(),
                userPlan,
                isPremiumPlan(userPlan)
        );
    }

    @Transactional
    public boolean isPremium(
            User user
    ) {

        return currentPlan(user).getCode() == PlanCode.PREMIUM;
    }

    public boolean isUnlimited(
            Integer limit
    ) {

        return limit == null;
    }

    public boolean isUnlimited(
            Long limit
    ) {

        return limit == null;
    }

    private UserPlan currentUserPlan(
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
