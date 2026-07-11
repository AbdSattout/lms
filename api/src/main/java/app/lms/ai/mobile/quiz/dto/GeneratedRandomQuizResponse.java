package app.lms.ai.mobile.quiz.dto;

import java.util.List;

public record GeneratedRandomQuizResponse(
        List<GeneratedRandomQuizQuestion> questions
) {
}