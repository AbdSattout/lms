package app.lms.tests.notification.controller;

import app.lms.tests.notification.dto.FirebasePushTestRequest;
import app.lms.tests.notification.dto.FirebasePushTestResponse;
import app.lms.tests.notification.service.FirebasePushTestService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@ConditionalOnProperty(
        prefix = "app.tests",
        name = "enabled",
        havingValue = "true"
)
@RequestMapping("/tests/notifications/firebase")
public class FirebasePushTestController {

    private final FirebasePushTestService firebasePushTestService;

    @PostMapping("/push")
    public ResponseEntity<FirebasePushTestResponse> send(
            @RequestBody @Valid
            FirebasePushTestRequest request
    ) {

        return ResponseEntity.ok(
                firebasePushTestService.send(request)
        );
    }
}
