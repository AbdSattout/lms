package app.lms.billing.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "polar")
public class PolarProperties {

    private String apiBaseUrl =
            "https://sandbox-api.polar.sh/v1";

    private String accessToken;

    private String premiumProductId;

    private String webhookSecret;

    private String checkoutSuccessUrl;

    private String checkoutReturnUrl;
}
