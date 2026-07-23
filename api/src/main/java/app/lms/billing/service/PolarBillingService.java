package app.lms.billing.service;

import app.lms.billing.client.PolarClient;
import app.lms.billing.dto.CheckoutSessionResponse;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PolarBillingService {

    private final PolarClient polarClient;

    public CheckoutSessionResponse createPremiumCheckout(
            User user
    ) {

        return polarClient.createPremiumCheckout(user);
    }
}
