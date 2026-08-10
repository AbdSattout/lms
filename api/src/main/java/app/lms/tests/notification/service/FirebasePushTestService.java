package app.lms.tests.notification.service;

import app.lms.tests.notification.dto.FirebasePushTestRequest;
import app.lms.tests.notification.dto.FirebasePushTestResponse;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@Slf4j
public class FirebasePushTestService {

    @Value("${firebase.service-account-base64:}")
    private String serviceAccountBase64;

    public FirebasePushTestResponse send(
            FirebasePushTestRequest request
    ) {

        LocalDateTime attemptedAt =
                LocalDateTime.now();

        String token =
                maskToken(request.token());

        if (FirebaseApp.getApps().isEmpty()) {
            log.warn(
                    "Firebase test push skipped because Firebase is not initialized. token={}",
                    token
            );

            return new FirebasePushTestResponse(
                    false,
                    isServiceAccountConfigured(),
                    serviceAccountBase64Length(),
                    false,
                    token,
                    null,
                    "FIREBASE_NOT_INITIALIZED",
                    "Firebase is not initialized. Check FIREBASE_SERVICE_ACCOUNT_BASE64.",
                    attemptedAt
            );
        }

        Message message =
                Message.builder()
                        .setToken(request.token())
                        .setNotification(
                                com.google.firebase.messaging.Notification
                                        .builder()
                                        .setTitle(defaultIfBlank(
                                                request.title(),
                                                "Firebase local test"
                                        ))
                                        .setBody(defaultIfBlank(
                                                request.message(),
                                                "Push test from local LMS API"
                                        ))
                                        .build()
                        )
                        .putData(
                                "debug",
                                "true"
                        )
                        .putData(
                                "source",
                                "local-api"
                        )
                        .build();

        try {
            String messageId =
                    FirebaseMessaging
                            .getInstance()
                            .send(message);

            log.info(
                    "Firebase test push sent. token={}, messageId={}",
                    token,
                    messageId
            );

            return new FirebasePushTestResponse(
                    true,
                    isServiceAccountConfigured(),
                    serviceAccountBase64Length(),
                    true,
                    token,
                    messageId,
                    null,
                    null,
                    attemptedAt
            );
        } catch (FirebaseMessagingException e) {
            log.error(
                    "Firebase test push failed. token={}, messagingErrorCode={}, message={}",
                    token,
                    e.getMessagingErrorCode(),
                    e.getMessage(),
                    e
            );

            return new FirebasePushTestResponse(
                    true,
                    isServiceAccountConfigured(),
                    serviceAccountBase64Length(),
                    false,
                    token,
                    null,
                    e.getMessagingErrorCode() != null
                            ? e.getMessagingErrorCode().name()
                            : "FIREBASE_MESSAGING_ERROR",
                    e.getMessage(),
                    attemptedAt
            );
        } catch (RuntimeException e) {
            log.error(
                    "Firebase test push failed unexpectedly. token={}, message={}",
                    token,
                    e.getMessage(),
                    e
            );

            return new FirebasePushTestResponse(
                    true,
                    isServiceAccountConfigured(),
                    serviceAccountBase64Length(),
                    false,
                    token,
                    null,
                    "UNEXPECTED_ERROR",
                    e.getMessage(),
                    attemptedAt
            );
        }
    }

    private boolean isServiceAccountConfigured() {

        return serviceAccountBase64 != null
                && !serviceAccountBase64.isBlank();
    }

    private int serviceAccountBase64Length() {

        if (serviceAccountBase64 == null) {
            return 0;
        }

        return serviceAccountBase64.trim().length();
    }

    private String defaultIfBlank(
            String value,
            String defaultValue
    ) {

        if (value == null || value.isBlank()) {
            return defaultValue;
        }

        return value;
    }

    private String maskToken(
            String token
    ) {

        if (token == null || token.isBlank()) {
            return "blank";
        }

        if (token.length() <= 12) {
            return "length-" + token.length();
        }

        return token.substring(0, 6)
                + "..."
                + token.substring(token.length() - 4)
                + " (length="
                + token.length()
                + ")";
    }
}
