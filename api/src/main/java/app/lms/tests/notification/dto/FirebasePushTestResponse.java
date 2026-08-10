package app.lms.tests.notification.dto;

import java.time.LocalDateTime;

public record FirebasePushTestResponse(
        boolean firebaseInitialized,
        boolean serviceAccountConfigured,
        int serviceAccountBase64Length,
        boolean sent,
        String token,
        String messageId,
        String errorCode,
        String errorMessage,
        LocalDateTime attemptedAt
) {
}
