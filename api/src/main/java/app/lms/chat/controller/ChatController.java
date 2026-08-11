package app.lms.chat.controller;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.service.ConversationService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chat/conversations")
@RequiredArgsConstructor
public class ChatController {

    private final ConversationService conversationService;

    @PostMapping("/direct/{targetUserId}")
    public ResponseEntity<ConversationResponse> createOrGetDirect(
            @PathVariable Long targetUserId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                conversationService.directConversation(
                        targetUserId,
                        principal.user()
                )
        );
    }
}