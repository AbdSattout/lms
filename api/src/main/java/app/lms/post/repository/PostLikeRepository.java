package app.lms.post.repository;

import app.lms.post.model.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;

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
}
