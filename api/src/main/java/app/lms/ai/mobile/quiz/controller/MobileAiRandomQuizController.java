package app.lms.ai.mobile.quiz.controller;

import app.lms.ai.mobile.quiz.dto.RandomQuizResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizSubmitResponse;
import app.lms.ai.mobile.quiz.dto.SubmitRandomQuizRequest;
import app.lms.ai.mobile.quiz.service.MobileAiRandomQuizService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/mobile/ai/courses/{courseId}/random-quiz")
@RequiredArgsConstructor
public class MobileAiRandomQuizController {

    private final MobileAiRandomQuizService mobileAiRandomQuizService;

    @PostMapping
    public ResponseEntity<RandomQuizResponse> generate(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobileAiRandomQuizService.generate(
                        courseId,
                        principal.user()
                )
        );
    }

    @PostMapping("/attempts/{attemptId}/submit")
    public ResponseEntity<RandomQuizSubmitResponse> submit(

            @PathVariable
            Long courseId,

            @PathVariable
            Long attemptId,

            @RequestBody
            @Valid
            SubmitRandomQuizRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobileAiRandomQuizService.submit(
                        courseId,
                        attemptId,
                        request,
                        principal.user()
                )
        );
    }
}