package app.lms.chat.dto;


import app.lms.chat.enums.MessageType;

import java.time.Instant;
import java.time.LocalDateTime;

public record MessageResponse(

        Long id,

        Long conversationId,

        Long senderId,

        String senderName,

        String senderPicture,

        String content,

        MessageType type,

        Instant createdAt,

        LocalDateTime editedAt,

        LocalDateTime deletedAt

) {
}
