package app.lms.billing.dto;

import app.lms.billing.enums.CheckoutClient;

public record CheckoutRequest(
        CheckoutClient client
) {

    public static CheckoutClient clientOrDefault(
            CheckoutRequest request
    ) {

        return request == null
                ? CheckoutClient.DEFAULT
                : request.clientOrDefault();
    }

    public CheckoutClient clientOrDefault() {

        return CheckoutClient.orDefault(
                client
        );
    }
}
