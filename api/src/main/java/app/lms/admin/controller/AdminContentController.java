package app.lms.admin.controller;

import app.lms.admin.security.AdminPrincipal;
import app.lms.admin.service.AdminContentService;
import app.lms.course.dto.CourseResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.post.dto.CommentResponse;
import app.lms.post.dto.PostResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin")
public class AdminContentController {

    private final AdminContentService adminContentService;

    @GetMapping("/organizations/{organizationId}")
    public ResponseEntity<OrganizationResponse> getOrganization(

            @PathVariable
            Long organizationId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminContentService.getOrganization(
                        organizationId,
                        admin.getId()
                )
        );
    }

    @GetMapping("/organizations/{organizationId}/courses")
    public ResponseEntity<Page<CourseResponse>> getOrganizationCourses(

            @PathVariable
            Long organizationId,

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminContentService.getOrganizationCourses(
                        organizationId,
                        admin.getId(),
                        pageable
                )
        );
    }

    @GetMapping("/organizations/{organizationId}/posts/{postId}")
    public ResponseEntity<PostResponse> getOrganizationPost(

            @PathVariable
            Long organizationId,

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminContentService.getOrganizationPost(
                        organizationId,
                        postId,
                        admin.getId()
                )
        );
    }

    @GetMapping("/users/{userId}/posts")
    public ResponseEntity<Page<PostResponse>> getUserPosts(

            @PathVariable
            Long userId,

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminContentService.getUserPosts(
                        userId,
                        admin.getId(),
                        pageable
                )
        );
    }

    @GetMapping("/users/{userId}/comments")
    public ResponseEntity<Page<CommentResponse>> getUserComments(

            @PathVariable
            Long userId,

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminContentService.getUserComments(
                        userId,
                        admin.getId(),
                        pageable
                )
        );
    }
}
