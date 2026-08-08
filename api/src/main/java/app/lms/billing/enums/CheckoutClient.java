package app.lms.billing.enums;

import java.util.Objects;

public enum CheckoutClient {
    WEB,
    MOBILE;

    public static final CheckoutClient DEFAULT =
            WEB;

    public static CheckoutClient orDefault(
            CheckoutClient client
    ) {

        return Objects.requireNonNullElse(
                client,
                DEFAULT
        );
    }
}
