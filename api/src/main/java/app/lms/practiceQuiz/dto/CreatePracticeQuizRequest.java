package app.lms.practiceQuiz.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CreatePracticeQuizRequest(

        @NotBlank
        String title,

        String description,

        @NotEmpty
        @Size(min = 1)
        List<Long> questionIds
) {
}