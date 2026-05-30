package app.lms.course.controller;

import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.service.CourseService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;

    @PostMapping(
            value = "/organizations/{name}/courses",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<CourseResponse> create(

            @PathVariable String name,

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
                                name,
                                request,
                                cover,
                                principal.user()
                        )
                );
    }

    @PatchMapping(
            value = "/courses/{courseId}",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<CourseResponse> update(

            @PathVariable Long courseId,

            @RequestPart
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

    @GetMapping("/organizations/{name}/courses")
    public ResponseEntity<Page<CourseResponse>> list(

            @PathVariable String name,

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                courseService.list(
                        name,
                        pageable
                )
        );
    }
}