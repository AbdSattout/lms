package app.lms.randomquiz.dto;

import app.lms.common.quiz.interfaces.SubmittedQuizAnswer;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SubmitBankRandomQuizAnswer(

        @NotNull
        Long questionId,

        @NotNull
        @Min(0)
        Integer answerIndex
) implements SubmittedQuizAnswer {
}