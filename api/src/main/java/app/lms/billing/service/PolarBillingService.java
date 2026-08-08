package app.lms.billing.service;

import app.lms.billing.client.PolarClient;
import app.lms.billing.dto.CheckoutRequest;
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

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PolarBillingService {

    private final PolarClient polarClient;
    private final UserPlanService userPlanService;
    private final UserPlanBillingService userPlanBillingService;
    private final PolarSubscriptionRepository polarSubscriptionRepository;

    public CheckoutSessionResponse createPremiumCheckout(
            User user
    ) {

        return createPremiumCheckout(
                user,
                CheckoutRequest.Client.WEB
        );
    }

    public CheckoutSessionResponse createPremiumCheckout(
            User user,
            CheckoutRequest.Client client
    ) {

        if (isPremiumPlan(
                userPlanService.getOrCreateCurrentPlan(user)
        )) {
            throw new ConflictException(
                    "User already has an active premium plan"
            );
        }

        return polarClient.createPremiumCheckout(
                user,
                client
        );
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
                currentPremiumSubscription(user);

        return polarClient.createCustomerPortalSession(
                polarSubscription.getPolarCustomerId()
        );
    }

    public void revokeSubscription(
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
                currentPremiumSubscription(user);

        polarClient.revokeSubscription(
                polarSubscription.getPolarSubscriptionId()
        );

        LocalDateTime now =
                LocalDateTime.now();

        polarSubscription.setStatus("canceled");
        polarSubscription.setCancelAtPeriodEnd(false);
        polarSubscription.setCanceledAt(now);
        polarSubscription.setRevokedAt(now);

        polarSubscriptionRepository.save(polarSubscription);
        userPlanBillingService.downgradeToFree(user);
    }

    private PolarSubscription currentPremiumSubscription(
            User user
    ) {

        return polarSubscriptionRepository
                .findFirstByUserIdOrderByCreatedAtDesc(
                        user.getId()
                )
                .orElseThrow(() ->
                        new BadRequestException(
                                "Polar subscription was not found for user"
                        )
                );
    }

    private boolean isPremiumPlan(
            Plan plan
    ) {

        return plan.getCode() == PlanCode.PREMIUM;
    }
}
