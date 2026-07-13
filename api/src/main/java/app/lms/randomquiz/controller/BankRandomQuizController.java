package app.lms.randomquiz.controller;

import app.lms.randomquiz.dto.BankRandomQuizResponse;
import app.lms.randomquiz.dto.BankRandomQuizSubmitResponse;
import app.lms.randomquiz.dto.GenerateBankRandomQuizRequest;
import app.lms.randomquiz.dto.SubmitBankRandomQuizRequest;
import app.lms.randomquiz.service.BankRandomQuizService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mobile/courses/{courseId}/random-quiz")
public class BankRandomQuizController {

    private final BankRandomQuizService bankRandomQuizService;

    @PostMapping
    public ResponseEntity<BankRandomQuizResponse> generate(
            @PathVariable Long courseId,
            @RequestBody @Valid GenerateBankRandomQuizRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                bankRandomQuizService.generate(
                        courseId,
                        request,
                        principal.user()
                )
        );
    }

    @PostMapping("/attempts/{attemptId}/submit")
    public ResponseEntity<BankRandomQuizSubmitResponse> submit(
            @PathVariable Long courseId,
            @PathVariable Long attemptId,
            @RequestBody @Valid SubmitBankRandomQuizRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                bankRandomQuizService.submit(
                        courseId,
                        attemptId,
                        request,
                        principal.user()
                )
        );
    }
}