package app.lms.billing.dto;

public record CheckoutRequest(
        Client client
) {

    public enum Client {
        WEB,
        MOBILE
    }

    public Client safeClient() {

        return client == null
                ? Client.WEB
                : client;
    }
}
