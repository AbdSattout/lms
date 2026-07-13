package app.lms.roadmap.controller;

import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.dto.UpsertRoadmapRequest;
import app.lms.roadmap.service.RoadmapService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class RoadmapController {

    private final RoadmapService roadmapService;

    @PostMapping("/dashboard/organizations/{slug}/roadmap")
    public ResponseEntity<RoadmapResponse> create(
            @PathVariable String slug,
            @RequestBody @Valid UpsertRoadmapRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        roadmapService.create(
                                slug,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/dashboard/organizations/{slug}/roadmap")
    public ResponseEntity<RoadmapResponse> update(
            @PathVariable String slug,
            @RequestBody @Valid UpsertRoadmapRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.update(
                        slug,
                        request,
                        principal.user()
                )
        );
    }

    @GetMapping("/dashboard/organizations/{slug}/roadmap")
    public ResponseEntity<RoadmapResponse> getManageable(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.getManageable(
                        slug,
                        principal.user()
                )
        );
    }

    @GetMapping("/organizations/{slug}/roadmap")
    public ResponseEntity<RoadmapResponse> getPublished(
            @PathVariable String slug
    ) {

        return ResponseEntity.ok(
                roadmapService.getPublished(
                        slug
                )
        );
    }
}
