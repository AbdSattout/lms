package app.lms.user.moderation.repository;

import app.lms.user.moderation.model.UserModeration;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserModerationRepository
        extends JpaRepository<UserModeration, Long> {

    boolean existsByUserId(
            Long userId
    );

    Optional<UserModeration> findByUserId(
            Long userId
    );
}
