package app.lms.quiz.controller;

import app.lms.question.dto.QuestionResponse;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.service.DashboardQuizService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/quizzes")
public class DashboardQuizController {

    private final DashboardQuizService dashboardQuizService;

    @GetMapping("/{quizId}")
    public ResponseEntity<QuizResponse> getQuizById(

            @PathVariable
            Long quizId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {
        return ResponseEntity.ok(
                dashboardQuizService.getQuizById(
                        quizId,
                        principal.user()
                )
        );
    }

    @PostMapping("/{quizId}/questions/{questionId}")
    public ResponseEntity<QuestionResponse> addQuestionToQuiz(

            @PathVariable
            Long quizId,

            @PathVariable
            Long questionId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        dashboardQuizService.addQuestionToQuiz(
                                quizId,
                                questionId,
                                principal.user()
                        )
                );
    }

    @DeleteMapping("/{quizId}/questions/{questionId}")
    public ResponseEntity<Void> deleteQuestionFromQuiz(

            @PathVariable
            Long quizId,

            @PathVariable
            Long questionId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {
        dashboardQuizService.deleteQuestionFromQuiz(
                quizId,
                questionId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }
}