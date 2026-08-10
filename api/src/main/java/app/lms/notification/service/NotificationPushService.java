package app.lms.notification.service;

import app.lms.notification.model.Notification;
import app.lms.notification.model.UserDevice;
import app.lms.notification.repository.NotificationRepository;
import app.lms.notification.repository.UserDeviceRepository;
import com.google.firebase.FirebaseApp;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class NotificationPushService {

    private final NotificationRepository notificationRepository;
    private final UserDeviceRepository userDeviceRepository;

    public void send(Long notificationId) {

        if (FirebaseApp.getApps().isEmpty()) {
            log.warn(
                    "Skipping push notification {} because Firebase is not initialized.",
                    notificationId
            );
            return;
        }

        Notification notification =
                notificationRepository
                        .findById(notificationId)
                        .orElse(null);

        if (notification == null) {
            log.warn(
                    "Skipping push notification {} because it was not found.",
                    notificationId
            );
            return;
        }

        List<UserDevice> devices =
                userDeviceRepository
                        .findAllByUserIdAndActiveTrue(
                                notification.getUser().getId()
                        );

        log.info(
                "Preparing push notification. notificationId={}, userId={}, type={}, activeDeviceCount={}",
                notification.getId(),
                notification.getUser().getId(),
                notification.getType(),
                devices.size()
        );

        if (devices.isEmpty()) {
            log.warn(
                    "No active devices found for push notification. notificationId={}, userId={}",
                    notification.getId(),
                    notification.getUser().getId()
            );
            return;
        }

        for (UserDevice device : devices) {

            sendToDevice(
                    notification,
                    device
            );
        }
    }

    private void sendToDevice(
            Notification notification,
            UserDevice device
    ) {

        Message message =
                Message.builder()
                        .setToken(
                                device.getToken()
                        )
                        .setNotification(
                                com.google.firebase.messaging.Notification
                                        .builder()
                                        .setTitle(
                                                notification.getTitle()
                                        )
                                        .setBody(
                                                notification.getMessage()
                                        )
                                        .build()
                        )
                        .putData(
                                "notificationId",
                                notification.getId().toString()
                        )
                        .putData(
                                "type",
                                notification.getType().name()
                        )
                        .putData(
                                "referenceType",
                                notification.getReferenceType() != null
                                        ? notification.getReferenceType()
                                        : ""
                        )
                        .putData(
                                "referenceId",
                                notification.getReferenceId() != null
                                        ? notification.getReferenceId().toString()
                                        : ""
                        )
                        .build();

        try {

            FirebaseMessaging
                    .getInstance()
                    .send(message);

            log.info(
                    "Firebase push sent. notificationId={}, deviceId={}, token={}",
                    notification.getId(),
                    device.getId(),
                    maskToken(device.getToken())
            );

        } catch (FirebaseMessagingException e) {

            log.error(
                    "Firebase push failed. notificationId={}, deviceId={}, token={}, messagingErrorCode={}, message={}",
                    notification.getId(),
                    device.getId(),
                    maskToken(device.getToken()),
                    e.getMessagingErrorCode(),
                    e.getMessage(),
                    e
            );
        } catch (RuntimeException e) {

            log.error(
                    "Firebase push failed unexpectedly. notificationId={}, deviceId={}, token={}, message={}",
                    notification.getId(),
                    device.getId(),
                    maskToken(device.getToken()),
                    e.getMessage(),
                    e
            );
        }
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
