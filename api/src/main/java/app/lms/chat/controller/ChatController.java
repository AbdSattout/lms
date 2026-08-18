package app.lms.chat.controller;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.dto.MuteResponse;
import app.lms.chat.service.ConversationService;
import app.lms.chat.service.ChatMuteService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chat/conversations")
@RequiredArgsConstructor
public class ChatController {

    private final ConversationService conversationService;

    private final ChatMuteService chatMuteService;

    @GetMapping
    public ResponseEntity<Page<ConversationResponse>> getConversations(
            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal(expression = "user")
            User user
    ) {

        return ResponseEntity.ok(
                conversationService.listConversations(
                        pageable,
                        user
                )
        );
    }

    @PostMapping("/direct/{targetUserId}")
    public ResponseEntity<ConversationResponse> createOrGetDirect(
            @PathVariable Long targetUserId,
            @AuthenticationPrincipal(expression = "user")
            User user
    ) {

        return ResponseEntity.ok(
                conversationService.directConversation(
                        targetUserId,
                        user
                )
        );
    }

    @GetMapping("/courses/{courseId}")
    public ResponseEntity<ConversationResponse> getCourseConversation(
            @PathVariable Long courseId,
            @AuthenticationPrincipal(expression = "user")
            User user
    ) {

        return ResponseEntity.ok(
                conversationService.courseConversation(
                        courseId,
                        user
                )
        );
    }

    @GetMapping("/{conversationId}/mutes")
    public ResponseEntity<List<MuteResponse>> getConversationMutes(
            @PathVariable Long conversationId,
            @AuthenticationPrincipal(expression = "user")
            User user
    ) {

        return ResponseEntity.ok(
                chatMuteService.listActiveMutes(
                        conversationId,
                        user
                )
        );
    }
}
