package app.lms.chat.exception;

import java.time.LocalDateTime;

public class ChatMutedException
        extends RuntimeException {

    private final LocalDateTime mutedUntil;

    public ChatMutedException(
            String message,
            LocalDateTime mutedUntil
    ) {
        super(message);
        this.mutedUntil = mutedUntil;
    }

    public LocalDateTime getMutedUntil() {
        return mutedUntil;
    }
}