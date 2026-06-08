package app.lms.post.repository;

import app.lms.post.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostRepository
        extends JpaRepository<Post, Long> {

    Page<Post> findByCourseId(
            long courseId,
            Pageable pageable
    );
}
