package app.lms.chat.dto;


import app.lms.chat.enums.ConversationType;

import java.time.LocalDateTime;

public record ConversationResponse(

        Long id,

        ConversationType type,

        Long courseId,

        Long directUserOneId,

        Long directUserTwoId,

        String lastMessagePreview,

        LocalDateTime lastMessageAt

) {
}