package app.lms.organization.repository;

import app.lms.organization.model.Post;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostRepository
        extends JpaRepository<Post, Long> {

    List<Post>
    findAllByOrganizationIdOrderByCreatedAtDesc(
            Long organizationId
    );

    List<Post>
    findAllByAuthorId(Long authorId);
}
