package app.lms.billing.repository;

import app.lms.billing.model.PolarSubscription;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PolarSubscriptionRepository
        extends JpaRepository<PolarSubscription, Long> {

    Optional<PolarSubscription> findByPolarSubscriptionId(
            String polarSubscriptionId
    );
}
