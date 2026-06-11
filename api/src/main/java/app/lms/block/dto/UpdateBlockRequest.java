package app.lms.block.dto;


import app.lms.question.dto.UpdateQuestionRequest;
import jakarta.validation.Valid;

public record UpdateBlockRequest(

        String title,

        String content,

        @Valid
        UpdateQuestionRequest question

) {
}