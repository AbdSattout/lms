package app.lms.analytics.organization.controller;

import app.lms.analytics.organization.dto.OrganizationDashboardResponse;
import app.lms.analytics.organization.service.OrganizationDashboardService;
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
@RequestMapping("/dashboard/details/organizations")
public class OrganizationDashboardController {

    private final OrganizationDashboardService dashboardService;

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationDashboardResponse> getDashboard(

            @PathVariable String slug,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardService.getDashboard(
                        slug,
                        principal.user()
                )
        );
    }
}
