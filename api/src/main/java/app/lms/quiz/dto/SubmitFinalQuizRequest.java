package app.lms.quiz.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record SubmitFinalQuizRequest(

        @NotEmpty
        List<@Valid SubmitFinalQuizAnswer> answers
) {
}