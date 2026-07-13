package app.lms.practiceQuiz.dto;

import app.lms.common.quiz.interfaces.SubmittedQuizAnswer;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;

public record SubmitPracticeQuizAnswer(

        @NotNull
        Long questionId,

        @NotNull
        @Min(0)
        Integer answerIndex
) implements SubmittedQuizAnswer {
}