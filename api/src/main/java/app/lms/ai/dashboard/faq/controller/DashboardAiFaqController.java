package app.lms.ai.dashboard.faq.controller;

import app.lms.ai.dashboard.faq.dto.GenerateCourseFaqRequest;
import app.lms.ai.dashboard.faq.service.DashboardAiFaqService;
import app.lms.faq.dto.CourseFaqResponse;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/dashboard/ai/courses/{courseId}/faq")
@RequiredArgsConstructor
public class DashboardAiFaqController {

    private final DashboardAiFaqService dashboardAiFaqService;

    @PostMapping("/generate")
    public ResponseEntity<List<CourseFaqResponse>> generate(

            @PathVariable
            Long courseId,

            @RequestBody
            @Valid
            GenerateCourseFaqRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardAiFaqService.generate(
                        courseId,
                        request,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<List<CourseFaqResponse>> getFaqs(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardAiFaqService.getFaqs(
                        courseId,
                        principal.user()
                )
        );
    }
}