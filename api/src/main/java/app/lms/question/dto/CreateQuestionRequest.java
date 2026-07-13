package app.lms.question.dto;

import app.lms.question.enums.QuestionDifficulty;
import jakarta.validation.constraints.*;

import java.util.List;

public record CreateQuestionRequest(

        @NotBlank
        @Size(max = 5000)
        String content,

        @NotEmpty
        @Size(min = 2, max = 6)
        List<@NotBlank String> options,

        @NotNull
        @Min(0)
        Integer correctAnswerIndex,

        QuestionDifficulty difficulty
) {
}