package app.lms.question.controller;

import app.lms.question.dto.CreateQuestionRequest;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.dto.UpdateQuestionRequest;
import app.lms.question.service.QuestionService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard")
public class QuestionController {

    private final QuestionService questionService;

    @PostMapping("/courses/{courseId}/questions")
    public ResponseEntity<QuestionResponse> create(

            @PathVariable
            Long courseId,

            @RequestBody
            @Valid
            CreateQuestionRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        questionService.create(
                                courseId,
                                request,
                                principal.user()
                        )
                );
    }

    @GetMapping("/courses/{courseId}/questions")
    public ResponseEntity<List<QuestionResponse>> getQuestionsByCourseId(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                questionService.getQuestionsByCourseId(
                        courseId,
                        principal.user()
                )
        );
    }

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

    @DeleteMapping("/questions/{questionId}")
    public ResponseEntity<Void> delete(

            @PathVariable
            Long questionId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        questionService.delete(
                questionId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}