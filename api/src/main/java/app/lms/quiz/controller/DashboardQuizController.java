package app.lms.quiz.controller;

import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.dto.UpdateFinalQuizQuestionsRequest;
import app.lms.quiz.service.DashboardQuizService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/courses/{courseId}/final-quiz")
public class DashboardQuizController {

    private final DashboardQuizService dashboardQuizService;

    @GetMapping
    public ResponseEntity<QuizResponse> getFinalQuiz(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardQuizService.getFinalQuizByCourseId(
                        courseId,
                        principal.user()
                )
        );
    }

    @PatchMapping("/questions")
    public ResponseEntity<QuizResponse> updateFinalQuizQuestions(
            @PathVariable Long courseId,
            @RequestBody @Valid UpdateFinalQuizQuestionsRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardQuizService.updateFinalQuizQuestions(
                        courseId,
                        request,
                        principal.user()
                )
        );
    }
}