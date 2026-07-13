package app.lms.quiz.dto;

import jakarta.validation.constraints.NotNull;

import java.util.List;

public record UpdateFinalQuizQuestionsRequest(

        @NotNull
        List<Long> questionIds

) {
}