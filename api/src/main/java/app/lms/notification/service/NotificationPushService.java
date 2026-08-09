package app.lms.notification.service;

import app.lms.notification.model.Notification;
import app.lms.notification.model.UserDevice;
import app.lms.notification.repository.NotificationRepository;
import app.lms.notification.repository.UserDeviceRepository;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationPushService {

    private final NotificationRepository notificationRepository;
    private final UserDeviceRepository userDeviceRepository;

    public void send(Long notificationId) {

        Notification notification =
                notificationRepository
                        .findById(notificationId)
                        .orElse(null);

        if (notification == null) {
            return;
        }

        List<UserDevice> devices =
                userDeviceRepository
                        .findAllByUserIdAndActiveTrue(
                                notification.getUser().getId()
                        );

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

        } catch (FirebaseMessagingException e) {

            System.err.println(
                    "Failed to send notification to device: "
                            + device.getId()
            );

            System.err.println(
                    e.getMessage()
            );
        }
    }
}