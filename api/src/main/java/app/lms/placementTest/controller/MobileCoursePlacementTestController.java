package app.lms.placementTest.controller;

import app.lms.placementTest.dto.PlacementTestResponse;
import app.lms.placementTest.dto.SubmitPlacementTestRequest;
import app.lms.placementTest.dto.SubmitPlacementTestResponse;
import app.lms.placementTest.service.CoursePlacementTestService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mobile/courses/{courseId}/placement-test")
public class MobileCoursePlacementTestController {

    private final CoursePlacementTestService coursePlacementTestService;

    @GetMapping
    public ResponseEntity<PlacementTestResponse> current(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                coursePlacementTestService.current(
                        courseId,
                        principal.user()
                )
        );
    }

    @PostMapping
    public ResponseEntity<SubmitPlacementTestResponse> submit(
            @PathVariable Long courseId,
            @RequestBody @Valid SubmitPlacementTestRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                coursePlacementTestService.submit(
                        courseId,
                        request,
                        principal.user()
                )
        );
    }

    @PostMapping("/skip")
    public ResponseEntity<PlacementTestResponse> skip(
            @PathVariable Long courseId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                coursePlacementTestService.skip(
                        courseId,
                        principal.user()
                )
        );
    }
}
