package app.lms.question.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.util.List;

public record UpdateQuestionRequest(

        @Pattern(
                regexp = "(?s).*\\S.*",
                message = "Question content cannot be empty"
        )
        @Size(
                max = 5000,
                message = "Question content must not exceed 5000 characters"
        )
        String content,

        @Size(
                min = 2,
                message = "Question must contain at least 2 options"
        )
        List<@NotBlank(message = "Question option cannot be empty") String> options,

        @Min(
                value = 0,
                message = "Correct answer index cannot be negative"
        )
        Integer correctAnswerIndex

) {
}