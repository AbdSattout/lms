package app.lms.practiceExam.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record SubmitPracticeExamRequest(

        @NotEmpty
        List<@Valid SubmitPracticeExamAnswer> answers
) {
}
