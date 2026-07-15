package app.lms.practiceExam.dto;

import java.util.List;

public record PracticeExamQuestionResultResponse(
        Long questionId,
        String content,
        List<String> options,
        Integer selectedAnswerIndex,
        Integer correctAnswerIndex,
        Boolean correct
) {
}
