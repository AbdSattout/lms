package app.lms.question.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CreateQuestionRequest(

        @NotBlank
        String content,

        @NotNull
        @Size(
                min = 2,
                message = "Question must contain at least 2 options"
        )
        List<@NotBlank String> options,

        @NotNull
        @Min(0)
        Integer correctAnswerIndex,
        Boolean shuffleOptions

) {
}