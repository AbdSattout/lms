package app.lms.media.controller;

import app.lms.media.dto.PostMediaResponse;
import app.lms.media.service.DashboardPostMediaService;
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
@RequestMapping("/dashboard/organizations/{slug}/post-media")
@RequiredArgsConstructor
public class DashboardPostMediaController {

    private final DashboardPostMediaService postMediaService;

    @PostMapping(
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> create(
            @PathVariable String slug,
            @RequestPart("file") MultipartFile file,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        postMediaService.create(
                                slug,
                                file,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            value = "/{mediaId}",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> update(
            @PathVariable String slug,
            @PathVariable Long mediaId,
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestPart(value = "name", required = false) String name,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.update(
                        slug,
                        mediaId,
                        file,
                        name,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{mediaId}")
    public ResponseEntity<Void> delete(
            @PathVariable String slug,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        postMediaService.delete(
                slug,
                mediaId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/{mediaId}")
    public ResponseEntity<PostMediaResponse> getById(
            @PathVariable String slug,
            @PathVariable Long mediaId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.getById(
                        slug,
                        mediaId,
                        principal.user()
                )
        );
    }

    @GetMapping
    public ResponseEntity<Page<PostMediaResponse>> list(
            @PathVariable String slug,
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.list(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }
}
