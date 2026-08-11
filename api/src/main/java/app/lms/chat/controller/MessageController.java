package app.lms.chat.controller;

import app.lms.chat.dto.EditMessageRequest;
import app.lms.chat.dto.MessageResponse;
import app.lms.chat.dto.SendMessageRequest;
import app.lms.chat.service.MessageService;
import app.lms.user.model.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/chat/conversations")
@RequiredArgsConstructor
public class MessageController {

    private final MessageService messageService;

    @PostMapping("/{conversationId}/messages")
    public MessageResponse sendMessage(
            @PathVariable Long conversationId,
            @Valid @RequestBody SendMessageRequest request,
            @AuthenticationPrincipal User user
    ) {

        return messageService.sendMessage(
                conversationId,
                request,
                user
        );
    }

    @GetMapping("/{conversationId}/messages")
    public Page<MessageResponse> getMessages(
            @PathVariable Long conversationId,
            Pageable pageable,
            @AuthenticationPrincipal User user
    ) {

        return messageService.getMessages(
                conversationId,
                user,
                pageable
        );
    }

    @PatchMapping("/{conversationId}/messages/{messageId}")
    public MessageResponse editMessage(
            @PathVariable Long conversationId,
            @PathVariable Long messageId,
            @Valid @RequestBody EditMessageRequest request,
            @AuthenticationPrincipal User user
    ) {

        return messageService.editMessage(
                conversationId,
                messageId,
                request,
                user
        );
    }

    @DeleteMapping("/{conversationId}/messages/{messageId}")
    public ResponseEntity<Void> deleteMessage(
            @PathVariable Long conversationId,
            @PathVariable Long messageId,
            @AuthenticationPrincipal User user
    ) {

        messageService.deleteMessage(
                conversationId,
                messageId,
                user
        );

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{conversationId}/messages/{messageId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long conversationId,
            @PathVariable Long messageId,
            @AuthenticationPrincipal User user
    ) {

        messageService.markAsRead(
                conversationId,
                messageId,
                user
        );

        return ResponseEntity.noContent().build();
    }
}