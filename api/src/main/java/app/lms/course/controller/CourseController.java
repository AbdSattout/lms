package app.lms.course.controller;

import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.service.CourseService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
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
public class CourseController {

    private final CourseService courseService;

    @PostMapping("/organizations/{slug}/courses")
    public ResponseEntity<CourseResponse> create(

            @PathVariable String slug,

            @RequestPart
            CreateCourseRequest request,

            @RequestPart(required = false)
            MultipartFile cover,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        courseService.create(
                                slug,
                                request,
                                cover,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/courses/{courseId}")
    public ResponseEntity<CourseResponse> update(

            @PathVariable Long courseId,

            @RequestPart @Valid
            UpdateCourseRequest request,

            @RequestPart(required = false)
            MultipartFile cover,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseService.update(
                        courseId,
                        request,
                        cover,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/courses/{courseId}")
    public ResponseEntity<Void> delete(

            @PathVariable Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        courseService.delete(
                courseId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/courses/{courseId}")
    public ResponseEntity<CourseResponse> getById(

            @PathVariable Long courseId
    ) {

        return ResponseEntity.ok(
                courseService.getById(
                        courseId
                )
        );
    }

    @GetMapping("/organizations/{slug}/courses")
    public ResponseEntity<Page<CourseResponse>> list(

            @PathVariable String slug,

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                courseService.list(
                        slug,
                        pageable
                )
        );
    }

    @PostMapping("/courses/{courseId}/publish")
    public ResponseEntity<Void> publish(

            @PathVariable Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        courseService.publish(
                courseId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }
}