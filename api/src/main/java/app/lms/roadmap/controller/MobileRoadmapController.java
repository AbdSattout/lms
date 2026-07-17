package app.lms.roadmap.controller;

import app.lms.roadmap.dto.RoadmapResponse;
import app.lms.roadmap.service.MobileRoadmapService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class MobileRoadmapController {

    private final MobileRoadmapService roadmapService;

    @GetMapping("/mobile/roadmaps")
    public ResponseEntity<Page<RoadmapResponse>> listAll(
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.listAll(
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/mobile/organizations/{slug}/roadmaps")
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

    @GetMapping("/mobile/organizations/{slug}/roadmaps/{roadmapId}")
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

    @PostMapping("/mobile/organizations/{slug}/roadmaps/{roadmapId}/follow")
    public ResponseEntity<RoadmapResponse> follow(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        roadmapService.follow(
                                slug,
                                roadmapId,
                                principal.user()
                        )
                );
    }

    @DeleteMapping("/mobile/organizations/{slug}/roadmaps/{roadmapId}/follow")
    public ResponseEntity<Void> unfollow(
            @PathVariable String slug,
            @PathVariable Long roadmapId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        roadmapService.unfollow(
                slug,
                roadmapId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/mobile/roadmaps/following")
    public ResponseEntity<Page<RoadmapResponse>> myRoadmaps(
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                roadmapService.myRoadmaps(
                        pageable,
                        principal.user()
                )
        );
    }
}
