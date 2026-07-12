package app.lms.quiz.controller;

import app.lms.quiz.dto.FinalQuizResponse;
import app.lms.quiz.dto.FinalQuizSubmitResponse;
import app.lms.quiz.dto.SubmitFinalQuizRequest;
import app.lms.quiz.service.MobileFinalQuizService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mobile/courses/{courseId}/quiz")
public class MobileFinalQuizController {

    private final MobileFinalQuizService mobileFinalQuizService;

    @GetMapping
    public ResponseEntity<FinalQuizResponse> getFinalQuiz(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobileFinalQuizService.getFinalQuiz(
                        courseId,
                        principal.user()
                )
        );
    }

    @PostMapping("/submit")
    public ResponseEntity<FinalQuizSubmitResponse> submit(
            @PathVariable Long courseId,
            @RequestBody @Valid SubmitFinalQuizRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobileFinalQuizService.submit(
                        courseId,
                        request,
                        principal.user()
                )
        );
    }
}