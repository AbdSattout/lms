package app.lms.practiceExam.controller;

import app.lms.practiceExam.dto.CreatePracticeExamRequest;
import app.lms.practiceExam.dto.PracticeExamResponse;
import app.lms.practiceExam.dto.UpdatePracticeExamQuestionsRequest;
import app.lms.practiceExam.service.DashboardPracticeExamService;
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
@RequestMapping("/dashboard/courses/{courseId}/practice-exams")
public class DashboardPracticeExamController {

    private final DashboardPracticeExamService dashboardPracticeExamService;

    @PostMapping
    public ResponseEntity<PracticeExamResponse> create(
            @PathVariable Long courseId,
            @RequestBody @Valid CreatePracticeExamRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        dashboardPracticeExamService.create(
                                courseId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/{practiceExamId}/questions")
    public ResponseEntity<PracticeExamResponse> updateQuestions(
            @PathVariable Long courseId,
            @PathVariable Long practiceExamId,
            @RequestBody @Valid UpdatePracticeExamQuestionsRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardPracticeExamService.updateQuestions(
                        courseId,
                        practiceExamId,
                        request,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<List<PracticeExamResponse>> list(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardPracticeExamService.list(
                        courseId,
                        principal.user()
                )
        );
    }

    @GetMapping("/{practiceExamId}")
    public ResponseEntity<PracticeExamResponse> getById(
            @PathVariable Long courseId,
            @PathVariable Long practiceExamId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardPracticeExamService.getById(
                        courseId,
                        practiceExamId,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{practiceExamId}")
    public ResponseEntity<Void> delete(
            @PathVariable Long courseId,
            @PathVariable Long practiceExamId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        dashboardPracticeExamService.delete(
                courseId,
                practiceExamId,
                principal.user()
        );

        return ResponseEntity.noContent()
                .build();
    }
}
