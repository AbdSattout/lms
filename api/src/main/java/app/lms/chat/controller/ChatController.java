package app.lms.chat.controller;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.service.ConversationService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chat/conversations")
@RequiredArgsConstructor
public class ChatController {

    private final ConversationService conversationService;

    @GetMapping
    public ResponseEntity<Page<ConversationResponse>> getConversations(
            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                conversationService.listConversations(
                        pageable,
                        principal.user()
                )
        );
    }

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

    @GetMapping("/courses/{courseId}")
    public ResponseEntity<ConversationResponse> getCourseConversation(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                conversationService.courseConversation(
                        courseId,
                        principal.user()
                )
        );
    }
}
