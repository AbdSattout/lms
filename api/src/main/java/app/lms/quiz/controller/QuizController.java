package app.lms.quiz.controller;

import app.lms.question.dto.QuestionResponse;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.service.QuizService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class QuizController {

    private final QuizService quizService;

    @GetMapping("/quizzes/{quizId}")
    public ResponseEntity<QuizResponse> getQuizById(
            @PathVariable
            Long quizId
    ) {
        return ResponseEntity.ok(
                quizService.getQuizById(quizId)
        );
    }

    @PostMapping("/{quizId}/questions/{questionId}")
    public ResponseEntity<QuestionResponse> addQuestionToQuiz(
            @PathVariable
            Long quizId,

            @PathVariable
            Long questionId,

            @AuthenticationPrincipal
            UserPrincipal userPrincipal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        quizService.addQuestionToQuiz(
                                quizId,
                                questionId,
                                userPrincipal.user()
                        )
                );
    }

    @DeleteMapping("/quizzes/{quizId}/questions/{questionId}")
    public ResponseEntity<Void> deleteQuestionFromQuiz(
            @PathVariable
            Long quizId,

            @PathVariable
            Long questionId,

            @AuthenticationPrincipal
            UserPrincipal userPrincipal
    ) {
        quizService.deleteQuestionFromQuiz(quizId, questionId, userPrincipal.user());
        return ResponseEntity.noContent().build();
    }
}
