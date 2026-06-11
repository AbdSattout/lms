package app.lms.progress.controller;

import app.lms.progress.dto.SubmitBlockAnswerRequest;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.service.ProgressService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class ProgressController {

    private final ProgressService progressService;

    @PostMapping("/blocks/{blockId}/submit")
    public ResponseEntity<SubmitBlockAnswerResponse> submitAnswer(

            @PathVariable
            Long blockId,

            @RequestBody
            @Valid
            SubmitBlockAnswerRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                progressService.submitAnswer(
                        blockId,
                        request,
                        principal.user()
                )
        );
    }
}