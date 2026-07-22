package app.lms.media.controller;

import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.service.DashboardCourseMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping(
        "/dashboard/organizations/{organizationId}/courses/{courseId}/media"
)
@RequiredArgsConstructor
public class DashboardCourseMediaController {

    private final DashboardCourseMediaService courseMediaService;

    @PostMapping(
            consumes = "multipart/form-data"
    )
    public ResponseEntity<CourseMediaResponse> create(
            @PathVariable Long organizationId,
            @PathVariable Long courseId,
            @RequestPart("file") MultipartFile file,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        courseMediaService.create(
                                organizationId,
                                courseId,
                                file,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            value = "/{mediaId}",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<CourseMediaResponse> update(
            @PathVariable Long organizationId,
            @PathVariable Long courseId,
            @PathVariable Long mediaId,
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestPart(value = "name", required = false) String name,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.update(
                        organizationId,
                        courseId,
                        mediaId,
                        file,
                        name,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{mediaId}")
    public ResponseEntity<Void> delete(
            @PathVariable Long organizationId,
            @PathVariable Long courseId,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        courseMediaService.delete(
                organizationId,
                courseId,
                mediaId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/{mediaId}")
    public ResponseEntity<CourseMediaResponse> getById(
            @PathVariable Long organizationId,
            @PathVariable Long courseId,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.getById(
                        organizationId,
                        courseId,
                        mediaId,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<Page<CourseMediaResponse>> list(
            @PathVariable Long organizationId,
            @PathVariable Long courseId,
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.list(
                        organizationId,
                        courseId,
                        pageable,
                        principal.user()
                )
        );
    }
}
