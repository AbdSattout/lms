package app.lms.notification.service;

import app.lms.notification.dto.RegisterDeviceRequest;
import app.lms.notification.model.UserDevice;
import app.lms.notification.repository.UserDeviceRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
@Slf4j
public class DeviceService {

    private final UserDeviceRepository userDeviceRepository;

    public void registerDevice(
            RegisterDeviceRequest request,
            User user
    ) {

        log.info(
                "Registering device token. userId={}, token={}",
                user.getId(),
                maskToken(request.token())
        );

        UserDevice device =
                userDeviceRepository
                        .findByToken(request.token())
                        .orElse(null);

        if (device != null) {

            device.setUser(user);
            device.setActive(true);
            device.setLastUsedAt(LocalDateTime.now());

            log.info(
                    "Reactivated existing device token. deviceId={}, userId={}, token={}",
                    device.getId(),
                    user.getId(),
                    maskToken(request.token())
            );

        } else {

            device = new UserDevice();
            device.setUser(user);
            device.setToken(request.token());
            device.setActive(true);
            device.setLastUsedAt(LocalDateTime.now());

            log.info(
                    "Creating new device token. userId={}, token={}",
                    user.getId(),
                    maskToken(request.token())
            );
        }

        UserDevice savedDevice =
                userDeviceRepository.save(device);

        log.info(
                "Device token saved. deviceId={}, userId={}, active={}, token={}",
                savedDevice.getId(),
                user.getId(),
                savedDevice.isActive(),
                maskToken(savedDevice.getToken())
        );
    }

    public void deactivateDevice(
            String token,
            User user
    ) {

        log.info(
                "Deactivating device token. userId={}, token={}",
                user.getId(),
                maskToken(token)
        );

        UserDevice device =
                userDeviceRepository
                        .findByTokenAndUserId(
                                token,
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Device not found"
                                )
                        );

        device.setActive(false);

        log.info(
                "Device token deactivated. deviceId={}, userId={}, token={}",
                device.getId(),
                user.getId(),
                maskToken(token)
        );
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
