package app.lms.chat.exception;

import java.time.LocalDateTime;

public class ChatMutedException
        extends RuntimeException {

    private final LocalDateTime mutedUntil;

    private final String reason;

    public ChatMutedException(
            String message,
            LocalDateTime mutedUntil
    ) {
        this(message, mutedUntil, null);
    }

    public ChatMutedException(
            String message,
            LocalDateTime mutedUntil,
            String reason
    ) {
        super(message);
        this.mutedUntil = mutedUntil;
        this.reason = reason;
    }

    public LocalDateTime getMutedUntil() {
        return mutedUntil;
    }

    public String getReason() {
        return reason;
    }
}