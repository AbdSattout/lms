package app.lms.question.dto;

import java.util.List;

public record QuestionResponse(

        Long id,

        String content,

        List<String> options,

        Integer correctAnswerIndex

) {
}