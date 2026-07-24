package app.lms.analytics.course.controller;

import app.lms.analytics.course.dto.CourseOverviewResponse;
import app.lms.analytics.course.service.CourseOverviewService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/overview/organizations")
public class CourseOverviewController {

    private final CourseOverviewService courseOverviewService;

    @GetMapping("/{slug}/courses/{courseId}")
    public ResponseEntity<CourseOverviewResponse> getDashboard(

            @PathVariable String slug,

            @PathVariable Long courseId,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseOverviewService.getOverview(
                        slug,
                        courseId,
                        principal.user()
                )
        );
    }
}
