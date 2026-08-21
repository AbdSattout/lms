package app.lms.practiceExam.dto;

import app.lms.common.quiz.interfaces.SubmittedQuizAnswer;
import jakarta.validation.constraints.NotNull;

public record SubmitPracticeExamAnswer(

        @NotNull
        Long questionId,

        @NotNull
        Integer answerIndex
) implements SubmittedQuizAnswer {
}
