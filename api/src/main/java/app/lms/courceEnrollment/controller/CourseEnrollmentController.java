package app.lms.courceEnrollment.controller;

import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
