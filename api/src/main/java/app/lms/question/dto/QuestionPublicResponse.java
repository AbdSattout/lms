package app.lms.question.dto;

import java.util.List;

public record QuestionPublicResponse(

        Long id,

        String content,

        List<String> options

) {
}