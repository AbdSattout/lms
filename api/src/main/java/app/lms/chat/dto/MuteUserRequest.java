package app.lms.chat.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

public record MuteUserRequest(

        @NotNull
        Long userId,

        @NotNull
        Long courseId,

        @NotNull
        Long conversationId,

        @NotNull
        @Positive
        Long durationMinutes,

        @Size(max = 500)
        String reason

) {
}
