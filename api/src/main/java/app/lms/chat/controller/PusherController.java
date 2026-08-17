package app.lms.chat.controller;

import app.lms.chat.service.PusherService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/chat/pusher")
@RequiredArgsConstructor
public class PusherController {

    private final PusherService pusherService;

    @PostMapping("/auth")
    public ResponseEntity<?> authenticate(
            @RequestParam String socketId,
            @RequestParam String channelName,
            @AuthenticationPrincipal(expression = "user") User user
    ) {
        return ResponseEntity.ok(
                pusherService.authenticate(
                        socketId,
                        channelName,
                        user
                )
        );
    }
}
