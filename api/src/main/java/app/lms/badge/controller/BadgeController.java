package app.lms.badge.controller;

import app.lms.badge.dto.BadgeResponse;
import app.lms.badge.service.BadgeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/badges")
public class BadgeController {

    private final BadgeService badgeService;

    @GetMapping
    public ResponseEntity<List<BadgeResponse>> getBadges() {

        return ResponseEntity.ok(
                badgeService.getBadges()
        );
    }
}
