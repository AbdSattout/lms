package app.lms.practiceExam.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.util.List;

public record CreatePracticeExamRequest(

        @NotBlank
        @Size(max = 255)
        String title,

        String description,

        @Positive
        Integer timeLimitMinutes,

        @NotEmpty
        List<Long> questionIds
) {
}
