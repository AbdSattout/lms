package app.lms.course.controller;

import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.service.CourseService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@RequestMapping("/organizations")
public class CourseController {

    private final CourseService courseService;

    @PostMapping(
            value = "/{name}/courses",
            consumes =
                    MediaType.MULTIPART_FORM_DATA_VALUE
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
}
