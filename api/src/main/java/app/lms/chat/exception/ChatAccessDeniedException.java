package app.lms.chat.exception;

public class ChatAccessDeniedException
        extends RuntimeException {

    public ChatAccessDeniedException(String message) {
        super(message);
    }
}