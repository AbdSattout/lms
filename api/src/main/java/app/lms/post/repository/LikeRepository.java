package app.lms.post.repository;

import app.lms.post.enums.LikeTargetType;
import app.lms.post.model.Like;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface LikeRepository
        extends JpaRepository<Like, Long> {

    Optional<Like> findByPostIdAndUserId(
            long postId,
            long userId
    );

    Optional<Like> findByCommentIdAndUserId(
            long commentId,
            long userId
    );

    @Query("""
            select postReaction.post.id as targetId,
                   postReaction.reactionType as reactionType,
                   count(postReaction) as reactionCount
            from UserLike postReaction
            where postReaction.targetType = :targetType
            and postReaction.post.id in :postIds
            group by postReaction.post.id, postReaction.reactionType
            """)
    List<ReactionCountProjection> countPostReactionsByPostIds(
            @Param("targetType") LikeTargetType targetType,
            @Param("postIds") List<Long> postIds
    );

    @Query("""
            select commentReaction.comment.id as targetId,
                   commentReaction.reactionType as reactionType,
                   count(commentReaction) as reactionCount
            from UserLike commentReaction
            where commentReaction.targetType = :targetType
            and commentReaction.comment.id in :commentIds
            group by commentReaction.comment.id, commentReaction.reactionType
            """)
    List<ReactionCountProjection> countCommentReactionsByCommentIds(
            @Param("targetType") LikeTargetType targetType,
            @Param("commentIds") List<Long> commentIds
    );

    @Query("""
            select postReaction
            from UserLike postReaction
            where postReaction.user.id = :userId
            and postReaction.targetType = :targetType
            and postReaction.post.id in :postIds
            """)
    List<Like> findByUserIdAndPostIds(
            @Param("userId") Long userId,
            @Param("targetType") LikeTargetType targetType,
            @Param("postIds") List<Long> postIds
    );

    @Query("""
            select commentReaction
            from UserLike commentReaction
            where commentReaction.user.id = :userId
            and commentReaction.targetType = :targetType
            and commentReaction.comment.id in :commentIds
            """)
    List<Like> findByUserIdAndCommentIds(
            @Param("userId") Long userId,
            @Param("targetType") LikeTargetType targetType,
            @Param("commentIds") List<Long> commentIds
    );
}
