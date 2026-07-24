package app.lms.analytics.user.controller;

import app.lms.analytics.user.dto.UserOverviewResponse;
import app.lms.analytics.user.service.UserOverviewService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/overview/me")
public class UserOverviewController {

    private final UserOverviewService userOverviewService;

    @GetMapping
    public ResponseEntity<UserOverviewResponse> getOverview(

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                userOverviewService.getOverview(
                        principal.user()
                )
        );
    }

}