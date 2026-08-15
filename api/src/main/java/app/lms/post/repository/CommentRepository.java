package app.lms.post.repository;

import app.lms.post.model.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface CommentRepository
        extends JpaRepository<Comment, Long> {

    List<Comment> findByPostId(long postId);

    List<Comment> findByPostIdOrderByCreatedAtAsc(Long postId);

    Page<Comment> findAllByAuthorId(
            Long authorId,
            Pageable pageable
    );
}
