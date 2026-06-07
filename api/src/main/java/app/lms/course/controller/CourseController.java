package app.lms.course.controller;

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





    @GetMapping("/courses/{courseId}")
    public ResponseEntity<CourseResponse> getById(

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

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                courseService.list(
                        slug,
                        pageable
                )
        );
    }





    @GetMapping("/courses/slug/{slug}")
    public ResponseEntity<CourseResponse> getBySlug(

            @PathVariable String slug
    ) {

        return ResponseEntity.ok(
                courseService.getBySlug(
                        slug
                )
        );
    }
}