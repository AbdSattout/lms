package app.lms.notification.listener;

import app.lms.notification.event.NotificationCreatedEvent;
import app.lms.notification.service.NotificationPushService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
@Slf4j
public class NotificationEventListener {

    private final NotificationPushService notificationPushService;

    @Async
    @TransactionalEventListener(
            phase = TransactionPhase.AFTER_COMMIT
    )
    public void handle(
            NotificationCreatedEvent event
    ) {

        log.info(
                "Notification push event received. notificationId={}",
                event.notificationId()
        );

        notificationPushService.send(
                event.notificationId()
        );
    }
}
