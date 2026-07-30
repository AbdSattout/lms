package app.lms.config;

import org.jspecify.annotations.NonNull;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;

import java.util.Collection;
import java.util.List;

import org.springframework.security.oauth2.core.DelegatingOAuth2TokenValidator;
import org.springframework.security.oauth2.core.OAuth2TokenValidator;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtClaimValidator;
import org.springframework.security.oauth2.jwt.JwtValidators;

@Configuration
public class JwtConfig {
    @Value("${telegram.client-id}")
    private String telegramClientId;

    @Value("${google.client-id}")
    private String googleClientId;

    @Bean
    public JwtDecoder telegramJwtDecoder() {

        NimbusJwtDecoder decoder =
                NimbusJwtDecoder
                        .withJwkSetUri(
                                "https://oauth.telegram.org/.well-known/jwks.json"
                        )
                        .build();

        OAuth2TokenValidator<Jwt> withIssuer =
                JwtValidators.createDefaultWithIssuer(
                        "https://oauth.telegram.org"
                );

        OAuth2TokenValidator<Jwt> withAudience =
                new JwtClaimValidator<List<String>>(
                        "aud",
                        aud -> aud.contains(telegramClientId)
                );

        OAuth2TokenValidator<Jwt> validator =
                new DelegatingOAuth2TokenValidator<>(
                        withIssuer,
                        withAudience
                );

        decoder.setJwtValidator(validator);

        return decoder;
    }

    @Bean
    public JwtDecoder googleJwtDecoder() {

        NimbusJwtDecoder decoder =
                NimbusJwtDecoder
                        .withJwkSetUri(
                                "https://www.googleapis.com/oauth2/v3/certs"
                        )
                        .build();

        OAuth2TokenValidator<Jwt> withDefaults =
                JwtValidators.createDefault();

        OAuth2TokenValidator<Jwt> withIssuer =
                new JwtClaimValidator<String>(
                        "iss",
                        iss -> "https://accounts.google.com".equals(iss) ||
                                "accounts.google.com".equals(iss)
                );

        OAuth2TokenValidator<Jwt> validator = getJwtOAuth2TokenValidator(withDefaults, withIssuer);

        decoder.setJwtValidator(validator);

        return decoder;
    }

    private @NonNull OAuth2TokenValidator<Jwt> getJwtOAuth2TokenValidator(OAuth2TokenValidator<Jwt> withDefaults, OAuth2TokenValidator<Jwt> withIssuer) {
        OAuth2TokenValidator<Jwt> withAudience =
                new JwtClaimValidator<>(
                        "aud",
                        aud -> audienceContains(
                                aud,
                                googleClientId
                        )
                );

        return new DelegatingOAuth2TokenValidator<>(
                withDefaults,
                withIssuer,
                withAudience
        );
    }

    private boolean audienceContains(
            Object audienceClaim,
            String clientId
    ) {

        if (audienceClaim instanceof String audience) {
            return audience.equals(clientId);
        }

        if (audienceClaim instanceof Collection<?> audiences) {
            return audiences.contains(clientId);
        }

        return false;
    }
}
