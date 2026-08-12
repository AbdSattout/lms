package app.lms.chat.dto;

import jakarta.validation.constraints.NotNull;

public record ReadMessageRequest(

        @NotNull
        Long messageId

) {}
