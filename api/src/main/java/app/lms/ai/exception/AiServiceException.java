package app.lms.ai.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class AiServiceException extends RuntimeException {

    private final HttpStatus status;

    public AiServiceException(
            String message,
            HttpStatus status,
            Throwable cause
    ) {
        super(message, cause);
        this.status = status;
    }
}