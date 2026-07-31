package app.lms.practiceExam.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record SubmitPracticeExamRequest(

        @NotNull
        Long attemptId,

        @NotEmpty
        List<@Valid SubmitPracticeExamAnswer> answers
) {
}
