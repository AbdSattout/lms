package app.lms.media.controller;

import app.lms.media.dto.PostMediaResponse;
import app.lms.media.service.PostMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/postMedia")
@RequiredArgsConstructor
public class    PostMediaController {

    private final PostMediaService
            postMediaService;

    @PostMapping(
            value = "/organizations/{slug}/media",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> create(

            @PathVariable
            String slug,

            @RequestPart("file")
            MultipartFile file,

            @AuthenticationPrincipal
            UserPrincipal principal
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
            value = "/organizations/{slug}/media/{mediaId}",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> update(

            @PathVariable
            String slug,

            @PathVariable
            Long mediaId,

            @RequestPart(value = "file", required = false)
            MultipartFile file,

            @RequestPart(value = "name", required = false)
            String name,

            @AuthenticationPrincipal
            UserPrincipal principal
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

    @DeleteMapping(
            "/organizations/{slug}/media/{mediaId}"
    )
    public ResponseEntity<Void> delete(

            @PathVariable
            String slug,

            @PathVariable
            Long mediaId,

            @AuthenticationPrincipal
            UserPrincipal principal
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


    @GetMapping(
            "/organizations/{slug}/media/{mediaId}"
    )
    public ResponseEntity<
            PostMediaResponse
            > getById(

            @PathVariable
            String slug,

            @PathVariable
            Long mediaId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.getById(
                        slug,
                        mediaId,
                        principal.user()
                )
        );
    }
    @GetMapping(
            "/organizations/{slug}/media"
    )
    public ResponseEntity<
            Page<PostMediaResponse>
            > list(

            @PathVariable
            String slug,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
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
