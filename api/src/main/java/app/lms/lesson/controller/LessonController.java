package app.lms.lesson.controller;

import app.lms.lesson.dto.*;
import app.lms.lesson.service.LessonService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class LessonController {

    private final LessonService lessonService;

    @GetMapping("/lessons/{lessonId}")
    public ResponseEntity<LessonDetailsResponse> getById(

            @PathVariable
            Long lessonId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                lessonService.getById(
                        lessonId,
                        principal.user()
                )
        );
    }

    @PostMapping(
            "/chapters/{chapterId}/lessons"
    )
    public ResponseEntity<LessonResponse> create(

            @PathVariable
            Long chapterId,

            @RequestBody
            @Valid
            CreateLessonRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        lessonService.create(
                                chapterId,
                                request,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            "/lessons/{lessonId}"
    )
    public ResponseEntity<LessonResponse> update(

            @PathVariable
            Long lessonId,

            @RequestBody
            @Valid
            UpdateLessonRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                lessonService.update(
                        lessonId,
                        request,
                        principal.user()
                )
        );
    }

    @DeleteMapping(
            "/lessons/{lessonId}"
    )
    public ResponseEntity<Void> delete(

            @PathVariable
            Long lessonId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        lessonService.delete(
                lessonId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PatchMapping(
            "/chapters/{chapterId}/lessons/reorder"
    )
    public ResponseEntity<Void> reorder(

            @PathVariable
            Long chapterId,

            @RequestBody
            @Valid
            ReorderLessonsRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        lessonService.reorder(
                chapterId,
                request,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/chapters/{chapterId}/lessons")
    public ResponseEntity<List<LessonResponse>> getLessonsByChapterId(

            @PathVariable
            Long chapterId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                lessonService.getLessonsByChapterId(
                        chapterId,
                        principal.user()
                )
        );
    }
}
