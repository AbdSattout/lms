package app.lms.practiceQuiz.controller;

import app.lms.practiceQuiz.dto.PracticeQuizPublicResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSubmitResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSummaryResponse;
import app.lms.practiceQuiz.dto.SubmitPracticeQuizRequest;
import app.lms.practiceQuiz.service.MobilePracticeQuizService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mobile/courses/{courseId}/practice-quizzes")
public class MobilePracticeQuizController {

    private final MobilePracticeQuizService mobilePracticeQuizService;

    @GetMapping("/{practiceQuizId}")
    public ResponseEntity<PracticeQuizPublicResponse> getPracticeQuiz(
            @PathVariable Long courseId,
            @PathVariable Long practiceQuizId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeQuizService.getPracticeQuiz(
                        courseId,
                        practiceQuizId,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<List<PracticeQuizSummaryResponse>> list(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeQuizService.list(
                        courseId,
                        principal.user()
                )
        );
    }
    @PostMapping("/{practiceQuizId}/submit")
    public ResponseEntity<PracticeQuizSubmitResponse> submit(
            @PathVariable Long courseId,
            @PathVariable Long practiceQuizId,
            @RequestBody @Valid SubmitPracticeQuizRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeQuizService.submit(
                        courseId,
                        practiceQuizId,
                        request,
                        principal.user()
                )
        );
    }
}