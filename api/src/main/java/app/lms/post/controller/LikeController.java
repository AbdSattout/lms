package app.lms.post.controller;

import app.lms.post.dto.ReactionRequest;
import app.lms.post.enums.ReactionType;
import app.lms.post.service.LikeService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class LikeController {

    private final LikeService likeService;

    @PostMapping("/posts/{postId}/likes")
    public ResponseEntity<Void> likePost(

            @PathVariable
            Long postId,

            @RequestBody(required = false)
            @Valid
            ReactionRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        likeService.likePost(
                postId,
                request != null
                        ? request.reactionType()
                        : ReactionType.LIKE,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @DeleteMapping("/posts/{postId}/likes")
    public ResponseEntity<Void> unlikePost(

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        likeService.unlikePost(
                postId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PostMapping("/comments/{commentId}/likes")
    public ResponseEntity<Void> likeComment(

            @PathVariable
            Long commentId,

            @RequestBody(required = false)
            @Valid
            ReactionRequest request,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        likeService.likeComment(
                commentId,
                request != null
                        ? request.reactionType()
                        : ReactionType.LIKE,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @DeleteMapping("/comments/{commentId}/likes")
    public ResponseEntity<Void> unlikeComment(

            @PathVariable
            Long commentId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        likeService.unlikeComment(
                commentId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}
