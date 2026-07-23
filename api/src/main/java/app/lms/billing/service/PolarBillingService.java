package app.lms.billing.service;

import app.lms.billing.client.PolarClient;
import app.lms.billing.dto.CheckoutSessionResponse;
import app.lms.billing.dto.CustomerPortalSessionResponse;
import app.lms.billing.model.PolarSubscription;
import app.lms.billing.repository.PolarSubscriptionRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.model.Plan;
import app.lms.plan.service.UserPlanService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PolarBillingService {

    private final PolarClient polarClient;
    private final UserPlanService userPlanService;
    private final PolarSubscriptionRepository polarSubscriptionRepository;

    public CheckoutSessionResponse createPremiumCheckout(
            User user
    ) {

        if (isPremiumPlan(
                userPlanService.getOrCreateCurrentPlan(user)
        )) {
            throw new ConflictException(
                    "User already has an active premium plan"
            );
        }

        return polarClient.createPremiumCheckout(user);
    }

    public CustomerPortalSessionResponse createCustomerPortalSession(
            User user
    ) {

        if (!isPremiumPlan(
                userPlanService.getOrCreateCurrentPlan(user)
        )) {
            throw new BadRequestException(
                    "User does not have an active premium plan"
            );
        }

        PolarSubscription polarSubscription =
                polarSubscriptionRepository
                        .findFirstByUserIdOrderByCreatedAtDesc(
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new BadRequestException(
                                        "Polar subscription was not found for user"
                                )
                        );

        return polarClient.createCustomerPortalSession(
                polarSubscription.getPolarCustomerId()
        );
    }

    private boolean isPremiumPlan(
            Plan plan
    ) {

        return plan.getCode() == PlanCode.PREMIUM;
    }
}
