package app.lms.roadmap.controller;

import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.dto.UpsertRoadmapRequest;
import app.lms.roadmap.service.DashboardRoadmapService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/organizations/{slug}/roadmaps")
public class DashboardRoadmapController {

    private final DashboardRoadmapService roadmapService;

    @PostMapping
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

    @GetMapping
    public ResponseEntity<Page<RoadmapResponse>> list(
            @PathVariable String slug,
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.list(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/{roadmapId}")
    public ResponseEntity<RoadmapResponse> getById(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.getById(
                        slug,
                        roadmapId,
                        principal.user()
                )
        );
    }

    @PatchMapping("/{roadmapId}")
    public ResponseEntity<RoadmapResponse> update(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @RequestBody @Valid UpsertRoadmapRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.update(
                        slug,
                        roadmapId,
                        request,
                        principal.user()
                )
        );
    }

    @PostMapping("/{roadmapId}/publish")
    public ResponseEntity<RoadmapResponse> publish(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.publish(
                        slug,
                        roadmapId,
                        principal.user()
                )
        );
    }

    @PostMapping("/{roadmapId}/draft")
    public ResponseEntity<RoadmapResponse> moveToDraft(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.moveToDraft(
                        slug,
                        roadmapId,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{roadmapId}")
    public ResponseEntity<Void> delete(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        roadmapService.delete(
                slug,
                roadmapId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}
