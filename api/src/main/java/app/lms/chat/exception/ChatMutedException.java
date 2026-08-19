package app.lms.chat.exception;

import java.time.Instant;

public class ChatMutedException
        extends RuntimeException {

    private final Instant mutedUntil;

    private final String reason;

    public ChatMutedException(
            String message,
            Instant mutedUntil
    ) {
        this(message, mutedUntil, null);
    }

    public ChatMutedException(
            String message,
            Instant mutedUntil,
            String reason
    ) {
        super(message);
        this.mutedUntil = mutedUntil;
        this.reason = reason;
    }

    public Instant getMutedUntil() {
        return mutedUntil;
    }

    public String getReason() {
        return reason;
    }
}