package app.lms.course.controller;

import app.lms.course.dto.CourseDetailsResponse;
import app.lms.course.dto.CourseResponse;
import app.lms.course.service.CourseService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class CourseController {

    private final CourseService courseService;


    @GetMapping("/courses")
    public ResponseEntity<Page<CourseResponse>> getAllCourses(
            @RequestParam(required = false)
            String q,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseService.getAll(
                        q,
                        pageable,
                        principal.user()
                )
        );
    }


    @GetMapping("/courses/{courseId}")
    public ResponseEntity<CourseDetailsResponse> getById(

            @PathVariable Long courseId,
            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseService.getById(
                        courseId,
                        principal.user()
                )
        );
    }

    @GetMapping("/organizations/{slug}/courses")
    public ResponseEntity<Page<CourseResponse>> list(

            @PathVariable String slug,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseService.list(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }





    @GetMapping(
            "/organizations/{organizationSlug}/courses/{courseSlug}"
    )
    public ResponseEntity<CourseResponse> getBySlug(

            @PathVariable String organizationSlug,

            @PathVariable String courseSlug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                courseService.getBySlug(
                        organizationSlug,
                        courseSlug,
                        principal.user()
                )
        );
    }
}
