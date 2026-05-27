package app.lms.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
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
}
