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

    @PostMapping("/courses/{courseId}/posts")
    public ResponseEntity<PostResponse> create(

            @PathVariable
            Long courseId,

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
                                courseId,
                                request,
                                principal.user()
                        )
                );
    }

    @GetMapping("/courses/{courseId}/posts")
    public ResponseEntity<Page<PostResponse>> getCoursePosts(

            @PathVariable
            Long courseId,

            Pageable pageable
    ) {

        return ResponseEntity.ok(
                postService.getCoursePosts(
                        courseId,
                        pageable
                )
        );
    }

    @GetMapping("/posts/{postId}")
    public ResponseEntity<PostResponse> getById(

            @PathVariable
            Long postId
    ) {

        return ResponseEntity.ok(
                postService.getById(postId)
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
}
