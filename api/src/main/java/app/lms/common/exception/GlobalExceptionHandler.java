package app.lms.common.exception;

import app.lms.ai.common.exception.AiServiceException;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.exception.ImageUploadException;
import app.lms.plan.exception.PlanLimitExceededException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.HttpMediaTypeNotSupportedException;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
@SuppressWarnings("unused")
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler
    public ResponseEntity<?> handleNotFound(NoResourceFoundException ex) {

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                Map.of(
                        "status", 404,
                        "error", "Not Found"
                )
        );
    }
    @ExceptionHandler(BadCredentialsException.class)
    public ResponseEntity<?> handleBadCredentials(BadCredentialsException ex) {

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(
                Map.of(
                        "status", 401,
                        "error", ex.getMessage()
                )
        );
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<?> handleHttpMessageNotReadable(
            HttpMessageNotReadableException ex
    ) {

        return ResponseEntity.badRequest().body(
                Map.of(
                        "status", 400,
                        "error", "Request body is missing or invalid"
                )
        );
    }
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleValidation(
            MethodArgumentNotValidException ex
    ) {

        Map<String, String> errors = new HashMap<>();

        ex.getBindingResult()
                .getFieldErrors()
                .forEach(error ->
                        errors.put(
                                error.getField(),
                                error.getDefaultMessage()
                        )
                );

        return ResponseEntity.badRequest().body(
                Map.of(
                        "status", 400,
                        "errors", errors
                )
        );
    }

    @ExceptionHandler(UsernameNotFoundException.class)
    public ResponseEntity<?> handleUsernameNotFound(
            UsernameNotFoundException ex
    ) {

        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(
                Map.of(
                        "status", 404,
                        "error", ex.getMessage()
                )
        );
    }
    @ExceptionHandler(MaxUploadSizeExceededException.class)
    public ResponseEntity<?> handleMaxSize(
            MaxUploadSizeExceededException ex
    ) {

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(
                Map.of(
                        "status", 400,
                        "error", ex.getMessage()
                )
        );
    }

    @ExceptionHandler(ImageUploadException.class)
    public ResponseEntity<?> handleImageUpload(
            ImageUploadException ex
    ) {

        return ResponseEntity.status(
                HttpStatus.INTERNAL_SERVER_ERROR
        ).body(
                Map.of(
                        "status", 500,
                        "error", ex.getMessage()
                )
        );
    }
    @ExceptionHandler(ImageDeleteException.class)
    public ResponseEntity<?> handleImageDelete(
            ImageDeleteException ex
    ) {

        return ResponseEntity.status(
                HttpStatus.INTERNAL_SERVER_ERROR
        ).body(
                Map.of(
                        "status", 500,
                        "error", ex.getMessage()
                )
        );
    }
    @ExceptionHandler(
            HttpRequestMethodNotSupportedException.class
    )
    public ResponseEntity<?> handleMethodNotSupported(
            HttpRequestMethodNotSupportedException ex
    ) {

        return ResponseEntity
                .status(HttpStatus.METHOD_NOT_ALLOWED)
                .body(
                        Map.of(
                                "status", 405,
                                "error", ex.getMessage()
                        )
                );
    }
    @ExceptionHandler(NotFoundException.class)
    public ResponseEntity<?> handleNotFoundException(
            NotFoundException ex
    ) {

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(
                        Map.of(
                                "status", 404,
                                "error", ex.getMessage()
                        )
                );
    }

    @ExceptionHandler(ConflictException.class)
    public ResponseEntity<?> handleConflictException(
            ConflictException ex
    ) {

        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(
                        Map.of(
                                "status", 409,
                                "error", ex.getMessage()
                        )
                );
    }

    @ExceptionHandler(PlanLimitExceededException.class)
    public ResponseEntity<?> handlePlanLimitExceededException(
            PlanLimitExceededException ex
    ) {

        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .body(
                        Map.of(
                                "status", 429,
                                "error", ex.getMessage()
                        )
                );
    }

    @ExceptionHandler(RedisConnectionFailureException.class)
    public ResponseEntity<?> handleRedisConnectionFailureException(
            RedisConnectionFailureException ex
    ) {

        log.error(
                "Redis connection failed",
                ex
        );

        return ResponseEntity.status(HttpStatus.SERVICE_UNAVAILABLE)
                .body(
                        Map.of(
                                "status", 503,
                                "error", "Redis is currently unavailable"
                        )
                );
    }

    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<?> handleForbiddenException(
            ForbiddenException ex
    ) {

        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(
                        Map.of(
                                "status", 403,
                                "error", ex.getMessage()
                        )
                );
    }

    @ExceptionHandler(
            HttpMediaTypeNotSupportedException.class
    )
    public ResponseEntity<?> handleUnsupportedMediaType(
            HttpMediaTypeNotSupportedException ex
    ) {

        return ResponseEntity
                .status(
                        HttpStatus.UNSUPPORTED_MEDIA_TYPE
                )
                .body(
                        Map.of(
                                "status", 415,
                                "error", ex.getMessage()
                        )
                );
    }

    @ExceptionHandler(AiServiceException.class)
    public ResponseEntity<?> handleAiServiceException(
            AiServiceException ex
    ) {
        return ResponseEntity.status(ex.getStatus()).body(
                Map.of(
                        "status", ex.getStatus().value(),
                        "error", ex.getMessage()
                )
        );
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<?> handleMethodArgumentTypeMismatch(
            MethodArgumentTypeMismatchException ex
    ) {
        return ResponseEntity.badRequest().body(
                Map.of(
                        "status", 400,
                        "error", "Invalid path parameter: " + ex.getName()
                )
        );
    }

    @ExceptionHandler(BadRequestException.class)
    public ResponseEntity<?> handleBadRequestException(
            BadRequestException ex
    ) {
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(
                        Map.of(
                                "status", 400,
                                "error", ex.getMessage()
                        )
                );
    }


}
