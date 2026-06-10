package app.lms.question.controller;

import app.lms.question.dto.QuestionResponse;
import app.lms.question.dto.UpdateQuestionRequest;
import app.lms.question.service.QuestionService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    @PatchMapping("/questions/{questionId}")
    public ResponseEntity<QuestionResponse> update(

            @PathVariable
            Long questionId,

            @RequestBody
            @Valid
            UpdateQuestionRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                questionService.update(
                        questionId,
                        request,
                        principal.user()
                )
        );
    }
}