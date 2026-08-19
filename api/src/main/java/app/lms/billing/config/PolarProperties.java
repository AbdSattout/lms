package app.lms.billing.config;

import app.lms.config.WebAppProperties;
import jakarta.annotation.PostConstruct;
import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "polar")
public class PolarProperties {

    private final WebAppProperties webAppProperties;

    private String apiBaseUrl =
            "https://sandbox-api.polar.sh/v1";

    private String accessToken;

    private String premiumProductId;

    private String webhookSecret;

    private String checkoutSuccessUrl;

    private String checkoutReturnUrl;

    private String webCheckoutSuccessUrl;

    private String webCheckoutReturnUrl;

    private String mobileCheckoutSuccessUrl;

    private String mobileCheckoutReturnUrl;

    private String customerPortalReturnUrl;

    public PolarProperties(
            WebAppProperties webAppProperties
    ) {
        this.webAppProperties = webAppProperties;
    }

    @PostConstruct
    void fillDefaults() {
        checkoutSuccessUrl = firstNonBlank(
                checkoutSuccessUrl,
                webAppProperties.url("/payment/success")
        );
        checkoutReturnUrl = firstNonBlank(
                checkoutReturnUrl,
                webAppProperties.url("/payment")
        );
        webCheckoutSuccessUrl = firstNonBlank(
                webCheckoutSuccessUrl,
                checkoutSuccessUrl
        );
        webCheckoutReturnUrl = firstNonBlank(
                webCheckoutReturnUrl,
                checkoutReturnUrl
        );
        mobileCheckoutSuccessUrl = firstNonBlank(
                mobileCheckoutSuccessUrl,
                webAppProperties.url("/mobile/billing/success")
        );
        mobileCheckoutReturnUrl = firstNonBlank(
                mobileCheckoutReturnUrl,
                webAppProperties.url("/mobile/billing/cancel")
        );
        customerPortalReturnUrl = firstNonBlank(
                customerPortalReturnUrl,
                webAppProperties.url("/payment")
        );
    }

    private static String firstNonBlank(
            String value,
            String fallback
    ) {
        return StringUtils.hasText(value)
                ? value
                : fallback;
    }
}
