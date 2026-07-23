package app.lms.media.controller;

import app.lms.media.dto.PostMediaResponse;
import app.lms.media.service.MobilePostMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/mobile/organizations/{organizationId}/post-media")
@RequiredArgsConstructor
public class MobilePostMediaController {

    private final MobilePostMediaService postMediaService;

    @GetMapping("/{mediaId}")
    public ResponseEntity<PostMediaResponse> getById(
            @PathVariable Long organizationId,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.getById(
                        organizationId,
                        mediaId,
                        principal.user()
                )
        );
    }
}
