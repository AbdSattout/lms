package app.lms.billing.controller;

import app.lms.billing.dto.CheckoutSessionResponse;
import app.lms.billing.dto.CheckoutRequest;
import app.lms.billing.dto.CustomerPortalSessionResponse;
import app.lms.billing.service.PolarBillingService;
import app.lms.billing.service.PolarWebhookService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/billing")
@RequiredArgsConstructor
public class BillingController {

    private final PolarBillingService polarBillingService;
    private final PolarWebhookService polarWebhookService;

    @PostMapping("/checkout")
    public ResponseEntity<CheckoutSessionResponse> createCheckout(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody(required = false) CheckoutRequest request
    ) {

        return ResponseEntity.ok(
                polarBillingService.createPremiumCheckout(
                        userPrincipal.user(),
                        CheckoutRequest.clientOrDefault(
                                request
                        )
                )
        );
    }

    @PostMapping("/portal")
    public ResponseEntity<CustomerPortalSessionResponse> createCustomerPortalSession(
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {

        return ResponseEntity.ok(
                polarBillingService.createCustomerPortalSession(
                        userPrincipal.user()
                )
        );
    }

    @PostMapping("/revoke")
    public ResponseEntity<Void> revokeSubscription(
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {

        polarBillingService.revokeSubscription(
                userPrincipal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PostMapping("/polar/webhook")
    public ResponseEntity<Void> handlePolarWebhook(
            @RequestBody String payload,
            @RequestHeader HttpHeaders headers
    ) {

        polarWebhookService.handle(
                payload,
                headers
        );

        return ResponseEntity
                .status(HttpStatus.ACCEPTED)
                .build();
    }
}
