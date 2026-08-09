package app.lms.notification.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.Base64;
import java.nio.charset.StandardCharsets;

@Configuration
public class FirebaseConfig {

    @Value("${firebase.service-account-base64}")
    private String serviceAccountBase64;

    @PostConstruct
    public void initialize() throws IOException {

        if (!FirebaseApp.getApps().isEmpty()) {
            return;
        }

        String serviceAccountJson = resolveServiceAccountJson();
        if (serviceAccountJson.isBlank()) {
            return;
        }

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
                throw new IOException(
                        "Invalid Firebase service account base64",
                        e
                );
            }
        }

        return "";
    }
}
