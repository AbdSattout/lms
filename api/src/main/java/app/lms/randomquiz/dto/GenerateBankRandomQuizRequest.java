package app.lms.randomquiz.dto;

import app.lms.question.enums.QuestionDifficulty;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record GenerateBankRandomQuizRequest(

        @NotNull
        QuestionDifficulty difficulty,

        @Min(1)
        @Max(50)
        Integer count
) {
}