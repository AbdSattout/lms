package app.lms.billing.repository;

import app.lms.billing.model.PolarWebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PolarWebhookEventRepository
        extends JpaRepository<PolarWebhookEvent, Long> {

    boolean existsByWebhookId(
            String webhookId
    );
}
