package app.lms.courceEnrollment.controller;

import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.course.dto.CourseResponse;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/courses")
public class CourseEnrollmentController {

    private final CourseEnrollmentService
            enrollmentService;

    private final CourseEnrollmentAccessService enrollmentAccessService;

    @PostMapping("/{courseId}/enroll")
    public ResponseEntity<EnrollmentResponse>
    enroll(

            @PathVariable Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        enrollmentService.enroll(
                                courseId,
                                principal.user()
                        )
                );
    }

    @DeleteMapping("/{courseId}/enroll")
    public ResponseEntity<Void> unenroll(

            @PathVariable Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        enrollmentService.unenroll(
                courseId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }
    @GetMapping("/me/enrollments")
    public ResponseEntity<Page<CourseResponse>> myCourses(

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                enrollmentAccessService.myCourses(
                        pageable,
                        principal.user()
                )
        );
    }
}
