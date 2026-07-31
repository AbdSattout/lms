package app.lms.course.controller;

import app.lms.admin.dto.BanRequest;
import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.dto.UpdateCourseRequest;
import app.lms.course.service.DashboardCourseService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RequiredArgsConstructor
@RestController
@RequestMapping("/dashboard")
public class DashboardCourseController {

   final DashboardCourseService dashboardCourseService;
    @PostMapping("/organizations/{slug}/courses")
    public ResponseEntity<CourseResponse> create(

            @PathVariable String slug,

            @RequestPart
            @Valid
            CreateCourseRequest request,

            @RequestPart(required = false)
            MultipartFile cover,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        dashboardCourseService.create(
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
                dashboardCourseService.update(
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

        dashboardCourseService.delete(
                courseId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/courses/{courseId}")
    public ResponseEntity<CourseResponse> getById(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardCourseService.getById(
                        courseId,
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
                dashboardCourseService.getBySlug(
                        organizationSlug,
                        courseSlug,
                        principal.user()
                )
        );
    }

    @GetMapping("/organizations/{slug}/courses")
    public ResponseEntity<List<CourseResponse>> getAll(

            @PathVariable
            String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardCourseService.list(
                        slug,
                        principal.user()
                )
        );
    }

    @PostMapping("/courses/{courseId}/publish")
    public ResponseEntity<Void> publish(

            @PathVariable Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        dashboardCourseService.publish(
                courseId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }
    @GetMapping(
            "/organizations/{slug}/courses/check-slug"
    )
    public ResponseEntity<Boolean> checkSlugAvailability(

            @PathVariable String slug,

            @RequestParam String courseSlug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardCourseService.isSlugAvailable(
                        slug,
                        courseSlug,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/courses/{courseId}/members/{memberId}")
    public ResponseEntity<Void> removeMember(
            @PathVariable Long courseId,
            @PathVariable Long memberId,
            @RequestBody
            @Valid
            BanRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        dashboardCourseService.removeMemberFromCourse(
                courseId,
                memberId,
                request,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }

}
