package app.lms.post.repository;

import app.lms.post.model.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface PostLikeRepository
        extends JpaRepository<PostLike, Long> {

    boolean existsByPostIdAndUserId(
            long postId,
            long userId
    );

    Optional<PostLike> findByPostIdAndUserId(
            long postId,
            long userId
    );

    @Query("""
            select postLike.post.id as postId,
                   postLike.reactionType as reactionType,
                   count(postLike) as reactionCount
            from PostLike postLike
            where postLike.post.id in :postIds
            group by postLike.post.id, postLike.reactionType
            """)
    List<PostReactionCountProjection> countReactionsByPostIds(
            @Param("postIds") List<Long> postIds
    );

    @Query("""
            select postLike
            from PostLike postLike
            where postLike.user.id = :userId
            and postLike.post.id in :postIds
            """)
    List<PostLike> findAllByUserIdAndPostIdIn(
            @Param("userId") Long userId,
            @Param("postIds") List<Long> postIds
    );
}
