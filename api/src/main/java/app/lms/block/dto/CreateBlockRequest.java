package app.lms.block.dto;

import app.lms.question.dto.CreateQuestionRequest;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;

public record CreateBlockRequest(

        @NotBlank
        String title,


        String content,

        @Valid
        CreateQuestionRequest question

) {
}
