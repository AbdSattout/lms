package app.lms.notification.repository;

import app.lms.notification.model.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserDeviceRepository
        extends JpaRepository<UserDevice, Long> {

    Optional<UserDevice> findByToken(
            String token
    );

    List<UserDevice> findAllByUserIdAndActiveTrue(
            Long userId
    );

    Optional<UserDevice> findByTokenAndUserId(
            String token,
            Long userId
    );
}