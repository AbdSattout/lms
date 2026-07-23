package app.lms.analytics.organization.controller;

import app.lms.analytics.organization.dto.OrganizationOverviewResponse;
import app.lms.analytics.organization.service.OrganizationOverviewService;
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
public class OrganizationOverviewController {

    private final OrganizationOverviewService organizationOverviewService;

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationOverviewResponse> getOverview(

            @PathVariable String slug,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationOverviewService.getOverview(
                        slug,
                        principal.user()
                )
        );
    }
}
