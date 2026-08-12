package app.lms.chat.controller;

import app.lms.chat.dto.MuteResponse;
import app.lms.chat.dto.MuteUserRequest;
import app.lms.chat.service.ChatMuteService;
import app.lms.user.model.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chat/mutes")
@RequiredArgsConstructor
public class ChatMuteController {

    private final ChatMuteService chatMuteService;

    @PostMapping
    public ResponseEntity<MuteResponse> mute(
            @Valid @RequestBody MuteUserRequest request,
            @AuthenticationPrincipal User user
    ) {

        return ResponseEntity.ok(
                chatMuteService.mute(
                        request,
                        user
                )
        );
    }

    @DeleteMapping("/{muteId}")
    public ResponseEntity<Void> unmute(
            @PathVariable Long muteId,
            @AuthenticationPrincipal User user
    ) {

        chatMuteService.unmute(
                muteId,
                user
        );

        return ResponseEntity.noContent().build();
    }
}