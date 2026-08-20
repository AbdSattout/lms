package app.lms.chat.dto;

import app.lms.chat.enums.ConversationType;
import app.lms.user.dto.UserResponse;

import java.time.Instant;

public record ConversationResponse(

        Long id,

        ConversationType type,

        Long courseId,

        UserResponse directUserOne,

        UserResponse directUserTwo,

        String lastMessagePreview,

        Instant lastMessageAt

) {
}