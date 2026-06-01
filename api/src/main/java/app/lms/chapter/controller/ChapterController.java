package app.lms.chapter.controller;

import app.lms.chapter.dto.ChapterResponse;
import app.lms.chapter.dto.CreateChapterRequest;
import app.lms.chapter.dto.ReorderChaptersRequest;
import app.lms.chapter.dto.UpdateChapterRequest;
import app.lms.chapter.service.ChapterService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class ChapterController {

    private final ChapterService chapterService;

    @PostMapping("/courses/{courseId}/chapters")
    public ResponseEntity<ChapterResponse> create(

            @PathVariable
            Long courseId,

            @RequestBody
            @Valid
            CreateChapterRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        chapterService.create(
                                courseId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/chapters/{chapterId}")
    public ResponseEntity<ChapterResponse> update(

            @PathVariable
            Long chapterId,

            @RequestBody @Valid
            UpdateChapterRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                chapterService.update(
                        chapterId,
                        request,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/chapters/{chapterId}")
    public ResponseEntity<Void> delete(

            @PathVariable
            Long chapterId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        chapterService.delete(
                chapterId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PatchMapping(
            "/courses/{courseId}/chapters/reorder"
    )
    public ResponseEntity<Void> reorder(

            @PathVariable
            Long courseId,

            @RequestBody
            @Valid
            ReorderChaptersRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        chapterService.reorder(
                courseId,
                request,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}