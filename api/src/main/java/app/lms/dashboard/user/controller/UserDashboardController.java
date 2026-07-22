package app.lms.dashboard.user.controller;

import app.lms.dashboard.user.dto.UserDashboardResponse;
import app.lms.dashboard.user.service.UserDashboardService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/details/me")
public class UserDashboardController {

    private final UserDashboardService dashboardService;

    @GetMapping
    public ResponseEntity<UserDashboardResponse> getDashboard(

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardService.getDashboard(
                        principal.user()
                )
        );
    }

}