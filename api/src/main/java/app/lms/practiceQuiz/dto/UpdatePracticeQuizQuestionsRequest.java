package app.lms.practiceQuiz.dto;

import jakarta.validation.constraints.NotNull;

import java.util.List;

public record UpdatePracticeQuizQuestionsRequest(

        @NotNull
        List<Long> questionIds

) {
}