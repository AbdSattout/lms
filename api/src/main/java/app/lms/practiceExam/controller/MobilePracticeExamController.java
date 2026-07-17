package app.lms.practiceExam.controller;

import app.lms.practiceExam.dto.PracticeExamPublicResponse;
import app.lms.practiceExam.dto.PracticeExamSubmitResponse;
import app.lms.practiceExam.dto.PracticeExamSummaryResponse;
import app.lms.practiceExam.dto.SubmitPracticeExamRequest;
import app.lms.practiceExam.service.MobilePracticeExamService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mobile/courses/{courseId}/practice-exams")
public class MobilePracticeExamController {

    private final MobilePracticeExamService mobilePracticeExamService;

    @GetMapping("/{practiceExamId}")
    public ResponseEntity<PracticeExamPublicResponse> getPracticeExam(
            @PathVariable Long courseId,
            @PathVariable Long practiceExamId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeExamService.getPracticeExam(
                        courseId,
                        practiceExamId,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<List<PracticeExamSummaryResponse>> list(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeExamService.list(
                        courseId,
                        principal.user()
                )
        );
    }

    @PostMapping("/{practiceExamId}/submit")
    public ResponseEntity<PracticeExamSubmitResponse> submit(
            @PathVariable Long courseId,
            @PathVariable Long practiceExamId,
            @RequestBody @Valid SubmitPracticeExamRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                mobilePracticeExamService.submit(
                        courseId,
                        practiceExamId,
                        request,
                        principal.user()
                )
        );
    }
}
