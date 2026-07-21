package app.lms.media.controller;

import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.service.MobileCourseMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(
        "/mobile/organizations/{organizationSlug}/courses/{courseSlug}/media"
)
@RequiredArgsConstructor
public class MobileCourseMediaController {

    private final MobileCourseMediaService courseMediaService;

    @GetMapping("/{mediaId}")
    public ResponseEntity<CourseMediaResponse> getById(
            @PathVariable String organizationSlug,
            @PathVariable String courseSlug,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.getById(
                        organizationSlug,
                        courseSlug,
                        mediaId,
                        principal.user()
                )
        );
    }
}
