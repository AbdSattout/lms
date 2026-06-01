package app.lms.courceEnrollment.controller;

import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
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
}
