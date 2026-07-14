package app.lms.practiceQuiz.controller;

import app.lms.practiceQuiz.dto.CreatePracticeQuizRequest;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.UpdatePracticeQuizQuestionsRequest;
import app.lms.practiceQuiz.service.DashboardPracticeQuizService;
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
@RequestMapping("/dashboard/courses/{courseId}/practice-quizzes")
public class DashboardPracticeQuizController {

    private final DashboardPracticeQuizService dashboardPracticeQuizService;

    @PostMapping
    public ResponseEntity<PracticeQuizResponse> create(
            @PathVariable Long courseId,
            @RequestBody @Valid CreatePracticeQuizRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        dashboardPracticeQuizService.create(
                                courseId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/{practiceQuizId}/questions")
    public ResponseEntity<PracticeQuizResponse> updateQuestions(
            @PathVariable Long courseId,
            @PathVariable Long practiceQuizId,
            @RequestBody @Valid UpdatePracticeQuizQuestionsRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardPracticeQuizService.updateQuestions(
                        courseId,
                        practiceQuizId,
                        request,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<List<PracticeQuizResponse>> list(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardPracticeQuizService.list(
                        courseId,
                        principal.user()
                )
        );
    }
}