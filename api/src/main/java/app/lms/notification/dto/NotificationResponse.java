package app.lms.notification.dto;

import app.lms.notification.enums.NotificationType;

import java.time.LocalDateTime;

public record NotificationResponse(

        Long id,

        NotificationType type,

        String title,

        String message,

        String referenceType,

        Long referenceId,

        boolean read,

        LocalDateTime readAt,

        LocalDateTime createdAt
) {
}