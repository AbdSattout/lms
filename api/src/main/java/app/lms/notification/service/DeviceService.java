package app.lms.notification.service;

import app.lms.notification.dto.RegisterDeviceRequest;
import app.lms.notification.model.UserDevice;
import app.lms.notification.repository.UserDeviceRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
@Transactional
public class DeviceService {

    private final UserDeviceRepository userDeviceRepository;

    public void registerDevice(
            RegisterDeviceRequest request,
            User user
    ) {

        UserDevice device =
                userDeviceRepository
                        .findByToken(request.token())
                        .orElseGet(UserDevice::new);

        device.setUser(user);
        device.setToken(request.token());
        device.setActive(true);
        device.setLastUsedAt(LocalDateTime.now());

        userDeviceRepository.save(device);
    }

    public void deactivateDevice(
            String token,
            User user
    ) {

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
    }
}
