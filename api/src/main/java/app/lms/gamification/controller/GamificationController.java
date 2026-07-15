package app.lms.gamification.controller;

import app.lms.gamification.dto.GamificationProgressResponse;
import app.lms.gamification.dto.ScoreboardResponse;
import app.lms.gamification.dto.UserActivityDayResponse;
import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.enums.ScoreboardPeriod;
import app.lms.gamification.service.GamificationService;
import app.lms.gamification.service.ScoreboardService;
import app.lms.gamification.service.UserActivityService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/gamification")
public class GamificationController {

    private final GamificationService gamificationService;
    private final UserActivityService userActivityService;
    private final ScoreboardService scoreboardService;

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

    @GetMapping("/activity")
    public ResponseEntity<List<UserActivityDayResponse>> activity(
            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate from,

            @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE)
            LocalDate to,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                userActivityService.getActivity(
                        principal.user(),
                        from,
                        to
                )
        );
    }

    @GetMapping("/streak")
    public ResponseEntity<UserStreakResponse> streak(
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                userActivityService.getStreak(
                        principal.user()
                )
        );
    }

    @GetMapping("/scoreboard")
    public ResponseEntity<ScoreboardResponse> scoreboard(
            @RequestParam(required = false)
            ScoreboardPeriod period,

            @RequestParam(required = false)
            Integer limit,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                scoreboardService.getScoreboard(
                        principal.user(),
                        period,
                        limit
                )
        );
    }
}
