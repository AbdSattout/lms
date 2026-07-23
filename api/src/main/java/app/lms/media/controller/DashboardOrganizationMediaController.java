package app.lms.media.controller;

import app.lms.media.dto.OrganizationMediaResponse;
import app.lms.media.dto.OrganizationMediaSummaryResponse;
import app.lms.media.service.DashboardOrganizationMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/organizations/{organizationId}/media-library")
public class DashboardOrganizationMediaController {

    private final DashboardOrganizationMediaService organizationMediaService;

    @GetMapping
    public ResponseEntity<Page<OrganizationMediaResponse>> list(
            @PathVariable Long organizationId,
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationMediaService.list(
                        organizationId,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/summary")
    public ResponseEntity<OrganizationMediaSummaryResponse> summary(
            @PathVariable Long organizationId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationMediaService.summary(
                        organizationId,
                        principal.user()
                )
        );
    }
}
