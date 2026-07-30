package app.lms.post.service;

import app.lms.common.exception.NotFoundException;
import app.lms.post.model.Post;
import app.lms.post.model.PostLike;
import app.lms.post.repository.PostLikeRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostLikeService {

    private final PostAccessService postAccessService;
    private final PostLikeRepository postLikeRepository;
    private final PostService postService;

    @Transactional
    public void like(
            Long postId,
            User user
    ) {

        Post post =
                postService
                        .findPostById(postId);

        postAccessService.validateInteractionAccess(
                post,
                user
        );

        if (post.getLikesCount() == null) {
            post.setLikesCount(0L);
        }

        boolean exists =
                postLikeRepository
                        .existsByPostIdAndUserId(
                                postId,
                                user.getId()
                        );

        if (exists) {
            return;
        }

        PostLike like =
                PostLike.builder()
                        .post(post)
                        .user(user)
                        .build();

        postLikeRepository.save(
                like
        );

        post.setLikesCount(
                post.getLikesCount() + 1
        );
    }

    @Transactional
    public void unlike(
            Long postId,
            User user
    ) {

        PostLike like =
                postLikeRepository
                        .findByPostIdAndUserId(
                                postId,
                                user.getId()
                        )
                        .orElseThrow(
                                () -> new NotFoundException(
                                        "Like not found"
                                )
                        );

        Post post = like.getPost();

        Long currentLikes = post.getLikesCount();
        if (currentLikes == null) {
            currentLikes = 0L;
        }

        post.setLikesCount(Math.max(0, currentLikes - 1));

        postLikeRepository.delete(
                like
        );
    }
}
