package app.lms.notification.service;


import app.lms.notification.dto.NotificationResponse;
import app.lms.notification.enums.NotificationType;
import app.lms.notification.mapper.NotificationMapper;
import app.lms.notification.model.Notification;
import app.lms.notification.repository.NotificationRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final NotificationMapper notificationMapper;

    public NotificationResponse create(
            User user,
            NotificationType type,
            String title,
            String message,
            String referenceType,
            Long referenceId
    ) {

        Notification notification =
                Notification.builder()
                        .user(user)
                        .type(type)
                        .title(title)
                        .message(message)
                        .referenceType(referenceType)
                        .referenceId(referenceId)
                        .read(false)
                        .build();

        notificationRepository.save(notification);

        notificationPushService.sendAsync(
                notification.getId()
        );

        return notificationMapper.toResponse(notification);
    }

    @Transactional()
    public Page<NotificationResponse> getMyNotifications(
            User user,
            Pageable pageable
    ) {

        return notificationRepository
                .findAllByUserIdOrderByCreatedAtDesc(
                        user.getId(),
                        pageable
                )
                .map(notificationMapper::toResponse);
    }

    @Transactional()
    public void getUnreadCount(
            User user
    ) {
                notificationRepository
                        .countByUserIdAndReadFalse(
                                user.getId()
                        );
    }

    public void markAsRead(
            Long notificationId,
            User user
    ) {

        Notification notification =
                notificationRepository
                        .findByIdAndUserId(
                                notificationId,
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Notification not found"
                                )
                        );

        if (!notification.isRead()) {

            notification.setRead(true);
            notification.setReadAt(LocalDateTime.now());
        }
    }

    public void markAllAsRead(
            User user
    ) {

        Page<Notification> notifications =
                notificationRepository
                        .findAllByUserIdOrderByCreatedAtDesc(
                                user.getId(),
                                Pageable.unpaged()
                        );

        LocalDateTime now = LocalDateTime.now();

        notifications.forEach(notification -> {

            if (!notification.isRead()) {

                notification.setRead(true);
                notification.setReadAt(now);
            }
        });
    }
}
