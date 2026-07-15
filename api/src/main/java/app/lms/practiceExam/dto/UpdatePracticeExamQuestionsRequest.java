package app.lms.practiceExam.dto;

import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record UpdatePracticeExamQuestionsRequest(

        @NotEmpty
        List<Long> questionIds
) {
}
