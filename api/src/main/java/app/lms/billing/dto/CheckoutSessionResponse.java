package app.lms.billing.dto;

public record CheckoutSessionResponse(
        String checkoutId,
        String checkoutUrl
) {
}
