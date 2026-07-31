package app.lms.post.service;

import app.lms.common.exception.NotFoundException;
import app.lms.post.enums.LikeTargetType;
import app.lms.post.enums.ReactionType;
import app.lms.post.model.Comment;
import app.lms.post.model.Like;
import app.lms.post.model.Post;
import app.lms.post.repository.LikeRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LikeService {

    private final PostAccessService postAccessService;
    private final PostService postService;
    private final CommentAccessService commentAccessService;
    private final LikeRepository likeRepository;

    @Transactional
    public void likePost(
            Long postId,
            ReactionType reactionType,
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

        Like existingLike =
                likeRepository
                        .findByPostIdAndUserId(
                                postId,
                                user.getId()
                        )
                        .orElse(null);

        if (existingLike != null) {
            existingLike.setReactionType(
                    resolveReactionType(reactionType)
            );
            return;
        }

        Like like =
                Like.builder()
                        .targetType(LikeTargetType.POST)
                        .post(post)
                        .user(user)
                        .reactionType(
                                resolveReactionType(reactionType)
                        )
                        .build();

        likeRepository.save(
                like
        );

        post.setLikesCount(
                post.getLikesCount() + 1
        );
    }

    @Transactional
    public void unlikePost(
            Long postId,
            User user
    ) {

        Like like =
                likeRepository
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

        likeRepository.delete(
                like
        );
    }

    @Transactional
    public void likeComment(
            Long commentId,
            ReactionType reactionType,
            User user
    ) {

        Comment comment =
                commentAccessService
                        .getById(commentId);

        postAccessService.validateInteractionAccess(
                comment.getPost(),
                user
        );

        if (comment.getLikesCount() == null) {
            comment.setLikesCount(0L);
        }

        Like existingLike =
                likeRepository
                        .findByCommentIdAndUserId(
                                commentId,
                                user.getId()
                        )
                        .orElse(null);

        if (existingLike != null) {
            existingLike.setReactionType(
                    resolveReactionType(reactionType)
            );
            return;
        }

        Like like =
                Like.builder()
                        .targetType(LikeTargetType.COMMENT)
                        .comment(comment)
                        .user(user)
                        .reactionType(
                                resolveReactionType(reactionType)
                        )
                        .build();

        likeRepository.save(
                like
        );

        comment.setLikesCount(
                comment.getLikesCount() + 1
        );
    }

    @Transactional
    public void unlikeComment(
            Long commentId,
            User user
    ) {

        Like like =
                likeRepository
                        .findByCommentIdAndUserId(
                                commentId,
                                user.getId()
                        )
                        .orElseThrow(
                                () -> new NotFoundException(
                                        "Like not found"
                                )
                        );

        Comment comment = like.getComment();

        Long currentLikes = comment.getLikesCount();
        if (currentLikes == null) {
            currentLikes = 0L;
        }

        comment.setLikesCount(Math.max(0, currentLikes - 1));

        likeRepository.delete(
                like
        );
    }

    private ReactionType resolveReactionType(
            ReactionType reactionType
    ) {

        return reactionType != null
                ? reactionType
                : ReactionType.LIKE;
    }
}
