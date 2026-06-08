package app.lms.post.controller;

import app.lms.post.dto.CommentResponse;
import app.lms.post.dto.CreateCommentRequest;
import app.lms.post.service.CommentService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @PostMapping("/posts/{postId}/comments")
    public ResponseEntity<CommentResponse> create(

            @PathVariable
            Long postId,

            @RequestBody
            @Valid
            CreateCommentRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        commentService.create(
                                postId,
                                request,
                                principal.user()
                        )
                );
    }

    @GetMapping("/posts/{postId}/comments")
    public ResponseEntity<List<CommentResponse>> getPostComments(

            @PathVariable
            Long postId
    ) {

        return ResponseEntity.ok(
                commentService.getPostComments(
                        postId
                )
        );
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void> delete(

            @PathVariable
            Long commentId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        commentService.delete(
                commentId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}
