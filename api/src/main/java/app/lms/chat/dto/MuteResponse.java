package app.lms.chat.dto;


import java.time.Instant;

public record MuteResponse(

        Long id,

        Long userId,

        Long courseId,

        Long conversationId,

        Instant mutedUntil,

        String reason,

        Long createdByInstructorId

) {
}