package app.lms.notification.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

@Configuration
@Lazy(false)
@Slf4j
public class FirebaseConfig {

    @Value("${firebase.service-account-base64}")
    private String serviceAccountBase64;

    @PostConstruct
    public void initialize() throws IOException {

        if (!FirebaseApp.getApps().isEmpty()) {
            log.info(
                    "Firebase already initialized. appCount={}",
                    FirebaseApp.getApps().size()
            );
            return;
        }

        String serviceAccountJson = resolveServiceAccountJson();
        if (serviceAccountJson.isBlank()) {
            log.warn(
                    "Firebase service account is empty. Push notifications are disabled. Set FIREBASE_SERVICE_ACCOUNT_BASE64 locally."
            );
            return;
        }

        log.info(
                "Initializing Firebase from service account. decodedJsonChars={}, projectId={}",
                serviceAccountJson.length(),
                extractProjectId(serviceAccountJson)
        );

        GoogleCredentials credentials =
                GoogleCredentials.fromStream(
                        new ByteArrayInputStream(
                                serviceAccountJson.getBytes(
                                        StandardCharsets.UTF_8
                                )
                        )
                );

        FirebaseOptions options =
                FirebaseOptions.builder()
                        .setCredentials(credentials)
                        .build();

        FirebaseApp.initializeApp(options);

        log.info(
                "Firebase initialized successfully. appCount={}",
                FirebaseApp.getApps().size()
        );
    }

    private String resolveServiceAccountJson() throws IOException {
        if (serviceAccountBase64 != null && !serviceAccountBase64.isBlank()) {
            try {
                byte[] decoded =
                        Base64
                                .getMimeDecoder()
                                .decode(serviceAccountBase64.trim());

                return new String(
                        decoded,
                        StandardCharsets.UTF_8
                );
            } catch (IllegalArgumentException e) {
                log.error(
                        "Firebase service account base64 is invalid. encodedChars={}",
                        serviceAccountBase64.trim().length()
                );
                throw new IOException(
                        "Invalid Firebase service account base64",
                        e
                );
            }
        }

        return "";
    }

    private String extractProjectId(
            String serviceAccountJson
    ) {

        String marker = "\"project_id\"";
        int keyIndex = serviceAccountJson.indexOf(marker);
        if (keyIndex < 0) {
            return "missing";
        }

        int colonIndex =
                serviceAccountJson.indexOf(
                        ":",
                        keyIndex + marker.length()
                );
        if (colonIndex < 0) {
            return "missing";
        }

        int firstQuoteIndex =
                serviceAccountJson.indexOf(
                        "\"",
                        colonIndex
                );
        if (firstQuoteIndex < 0) {
            return "missing";
        }

        int secondQuoteIndex =
                serviceAccountJson.indexOf(
                        "\"",
                        firstQuoteIndex + 1
                );
        if (secondQuoteIndex < 0) {
            return "missing";
        }

        return serviceAccountJson.substring(
                firstQuoteIndex + 1,
                secondQuoteIndex
        );
    }
}
