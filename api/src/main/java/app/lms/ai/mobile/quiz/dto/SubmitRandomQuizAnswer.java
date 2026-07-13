package app.lms.ai.mobile.quiz.dto;

import app.lms.common.quiz.interfaces.SubmittedQuizAnswer;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SubmitRandomQuizAnswer(
        @NotNull
        Long questionId,

        @NotNull
        @Min(0)
        Integer answerIndex
)  implements SubmittedQuizAnswer {
}