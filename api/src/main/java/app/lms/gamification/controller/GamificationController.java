package app.lms.gamification.controller;

import app.lms.gamification.dto.GamificationProgressResponse;
import app.lms.gamification.service.GamificationService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/gamification")
public class GamificationController {

    private final GamificationService gamificationService;

    @GetMapping("/me")
    public ResponseEntity<GamificationProgressResponse> me(
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                gamificationService.getProgress(
                        principal.user()
                )
        );
    }
}
