package app.lms.post.repository;

import app.lms.post.model.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;

public interface CommentRepository
        extends JpaRepository<Comment, Long> {

    List<Comment> findByPostId(long postId);

    List<Comment> findByPostIdOrderByCreatedAtAsc(Long postId);

    Page<Comment> findAllByAuthorId(
            Long authorId,
            Pageable pageable
    );

    long countByPostId(Long postId);

    @Query("""
            select comment.post.id as postId,
                   count(comment.id) as commentCount
            from Comment comment
            where comment.post.id in :postIds
            group by comment.post.id
            """)
    List<PostCommentCountProjection> countByPostIds(
            @Param("postIds") Collection<Long> postIds
    );
    List<Comment> findByPostIdIn(
            Collection<Long> postIds
    );
}
