package app.lms.chat.dto;


import app.lms.chat.enums.MessageType;

import java.time.LocalDateTime;

public record MessageResponse(

        Long id,

        Long conversationId,

        Long senderId,

        String senderName,

        String content,

        MessageType type,

        LocalDateTime createdAt,

        LocalDateTime editedAt,

        LocalDateTime deletedAt

) {
}