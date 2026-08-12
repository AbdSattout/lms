package app.lms.chat.dto;


import java.time.LocalDateTime;

public record MuteResponse(

        Long id,

        Long userId,

        Long courseId,

        Long conversationId,

        LocalDateTime mutedUntil,

        String reason,

        Long createdByInstructorId

) {
}