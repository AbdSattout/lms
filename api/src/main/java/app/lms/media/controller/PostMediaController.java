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
public class PostMediaController {

    private final PostMediaService
            postMediaService;

    @PostMapping(
            value = "/posts/{postId}/media",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> create(

            @PathVariable
            Long postId,

            @RequestPart("file")
            MultipartFile file,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        postMediaService.create(
                                postId,
                                file,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            value = "/media/{mediaId}",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<PostMediaResponse> update(

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
                        mediaId,
                        file,
                        name,
                        principal.user()
                )
        );
    }

    @DeleteMapping(
            "/media/{mediaId}"
    )
    public ResponseEntity<Void> delete(

            @PathVariable
            Long mediaId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        postMediaService.delete(
                mediaId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }


    @GetMapping(
            "/media/{mediaId}"
    )
    public ResponseEntity<
            PostMediaResponse
            > getById(

            @PathVariable
            Long mediaId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.getById(
                        mediaId,
                        principal.user()
                )
        );
    }
    @GetMapping(
            "/posts/{postId}/media"
    )
    public ResponseEntity<
            Page<PostMediaResponse>
            > list(

            @PathVariable
            Long postId,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postMediaService.list(
                        postId,
                        pageable,
                        principal.user()
                )
        );
    }

}
