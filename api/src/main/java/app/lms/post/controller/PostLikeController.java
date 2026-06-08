package app.lms.post.controller;

import app.lms.post.service.PostLikeService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class PostLikeController {

    private final PostLikeService postLikeService;

    @PostMapping("/posts/{postId}/likes")
    public ResponseEntity<Void> like(

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        postLikeService.like(
                postId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @DeleteMapping("/posts/{postId}/likes")
    public ResponseEntity<Void> unlike(

            @PathVariable
            Long postId,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        postLikeService.unlike(
                postId,
                principal.user()
        );

        return ResponseEntity
                .noContent()
                .build();
    }
}
