package app.lms.randomquiz.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record SubmitBankRandomQuizRequest(

        @NotEmpty
        List<@Valid SubmitBankRandomQuizAnswer> answers
) {
}