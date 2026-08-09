package app.lms.notification.controller;

import app.lms.notification.dto.RegisterDeviceRequest;
import app.lms.notification.service.DeviceService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/devices")
@RequiredArgsConstructor
public class DeviceController {

    private final DeviceService deviceService;

    @PostMapping
    public void registerDevice(
            @Valid @RequestBody RegisterDeviceRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        deviceService.registerDevice(
                request,
                principal.user()
        );
    }

    @DeleteMapping
    public void deactivateDevice(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        deviceService.deactivateDevice(
                token,
                principal.user()
        );
    }
}
