package app.lms.post.repository;

import app.lms.post.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PostRepository
        extends JpaRepository<Post, Long> {

    Page<Post> findByCourseId(
            long courseId,
            Pageable pageable
    );

    Page<Post> findByOrganizationIdAndCourseIsNull(
            Long organizationId,
            Pageable pageable
    );

    List<Post> findAllByOrganizationIdAndCourseIsNullOrderByCreatedAtDesc(
            Long organizationId
    );

    List<Post> findAllByOrganizationIdAndCourseIdInOrderByCreatedAtDesc(
            Long organizationId,
            List<Long> courseIds
    );

    Optional<Post> findByIdAndOrganizationId(
            Long id,
            Long organizationId
    );

    void deleteByOrganizationId(
            Long organizationId
    );

    long countByOrganizationId(Long organizationId);
}
