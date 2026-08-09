package app.lms.notification.listener;

import app.lms.notification.event.NotificationCreatedEvent;
import app.lms.notification.service.NotificationPushService;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

@Component
@RequiredArgsConstructor
public class NotificationEventListener {

    private final NotificationPushService notificationPushService;

    @Async
    @TransactionalEventListener(
            phase = TransactionPhase.AFTER_COMMIT
    )
    public void handle(
            NotificationCreatedEvent event
    ) {

        notificationPushService.send(
                event.notificationId()
        );
    }
}
