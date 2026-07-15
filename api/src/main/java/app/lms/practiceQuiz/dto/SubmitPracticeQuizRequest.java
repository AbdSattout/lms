package app.lms.practiceQuiz.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record SubmitPracticeQuizRequest(

        @NotEmpty
        List<@Valid SubmitPracticeQuizAnswer> answers
) {
}