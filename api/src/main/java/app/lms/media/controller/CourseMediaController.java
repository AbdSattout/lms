package app.lms.media.controller;

import app.lms.media.dto.CourseMediaResponse;
import app.lms.media.service.CourseMediaService;
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
@RequiredArgsConstructor
public class CourseMediaController {

    private final CourseMediaService
            courseMediaService;

    @PostMapping(
            value = "/courses/{courseId}/media",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<CourseMediaResponse> create(

            @PathVariable
            Long courseId,

            @RequestPart("file")
            MultipartFile file,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        courseMediaService.create(
                                courseId,
                                file,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            value = "/media/{mediaId}",
            consumes = "multipart/form-data"
    )
    public ResponseEntity<CourseMediaResponse> update(

            @PathVariable
            Long mediaId,

            @RequestPart("file")
            MultipartFile file,
            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.update(
                        mediaId,
                        file,
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

        courseMediaService.delete(
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
            CourseMediaResponse
            > getById(

            @PathVariable
            Long mediaId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.getById(
                        mediaId,
                        principal.user()
                )
        );
    }
    @GetMapping(
            "/courses/{courseId}/media"
    )
    public ResponseEntity<
            Page<CourseMediaResponse>
            > list(

            @PathVariable
            Long courseId,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseMediaService.list(
                        courseId,
                        pageable,
                        principal.user()
                )
        );
    }

}