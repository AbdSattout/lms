package app.lms.post.controller;

import app.lms.post.dto.CreatePostRequest;
import app.lms.post.dto.PostResponse;
import app.lms.post.dto.UpdatePostRequest;
import app.lms.post.service.PostService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class PostController {

    private final PostService postService;

    @PostMapping("/organizations/{slug}/posts")
    public ResponseEntity<PostResponse> create(

            @PathVariable
            String slug,

            @RequestBody
            @Valid
            CreatePostRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        postService.create(
                                slug,
                                request,
                                principal.user()
                        )
                );
    }

    @GetMapping("/organizations/{slug}/posts")
    public ResponseEntity<Page<PostResponse>> getOrganizationPosts(

            @PathVariable
            String slug,

            @AuthenticationPrincipal
            UserPrincipal principal,

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                postService.getOrganizationPosts(
                        slug,
                        principal.user(),
                        pageable
                )
        );
    }

    @GetMapping("/organizations/{slug}/posts/{postId}")
    public ResponseEntity<PostResponse> getOrganizationPostById(

            @PathVariable
            String slug,

            @PathVariablepos
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postService.getById(slug,postId,principal.user())
        );
    }
    @GetMapping("/courses/{courseId}/posts/{postId}")
    public ResponseEntity<PostResponse> getCoursePostById(

            @PathVariable
            Long courseId,

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postService.getCoursePostById(
                        courseId,
                        postId,
                        principal.user()
                )
        );
    }

    @PatchMapping("/posts/{postId}")
    public ResponseEntity<PostResponse> update(

            @PathVariable
            Long postId,

            @RequestBody
            @Valid
            UpdatePostRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                postService.update(
                        postId,
                        request,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<Void> delete(

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        postService.delete(
                postId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @GetMapping("/courses/{courseId}/posts")
    public ResponseEntity<Page<PostResponse>> getCoursePosts(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            UserPrincipal principal,

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                postService.getCoursePosts(
                        courseId,
                        principal.user(),
                        pageable
                )
        );
    }
}
