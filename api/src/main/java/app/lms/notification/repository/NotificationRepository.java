package app.lms.notification.repository;

import app.lms.notification.model.Notification;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface NotificationRepository
        extends JpaRepository<Notification, Long> {

    Page<Notification> findAllByUserIdOrderByCreatedAtDesc(
            Long userId,
            Pageable pageable
    );

    long countByUserIdAndReadFalse(
            Long userId
    );

    Optional<Notification> findByIdAndUserId(
            Long id,
            Long userId
    );
}
