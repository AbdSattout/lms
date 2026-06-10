package app.lms.question.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;

import java.util.List;

public record UpdateQuestionRequest(

        String content,

        @Size(
                min = 2,
                message = "Question must contain at least 2 options"
        )
        List<String> options,

        @Min(0)
        Integer correctAnswerIndex

) {
}