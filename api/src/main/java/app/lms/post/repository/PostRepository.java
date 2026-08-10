package app.lms.post.repository;

import app.lms.organization.repository.projection.OrganizationCountProjection;
import app.lms.post.model.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface PostRepository extends JpaRepository<Post, Long> {

    Page<Post> findByCourseId(
            long courseId,
            Pageable pageable
    );

    Page<Post> findByOrganizationIdAndCourseIsNull(
            Long organizationId,
            Pageable pageable
    );

    Optional<Post> findByIdAndOrganizationId(
            Long id,
            Long organizationId
    );

    Optional<Post> findByIdAndCourseId(
            Long id,
            Long courseId
    );

    void deleteByOrganizationId(
            Long organizationId
    );

    long countByOrganizationId(Long organizationId);

    @Query("""
            select post.organization.id as organizationId,
                   count(post.id) as total
            from Post post
            where post.organization.id in :organizationIds
            group by post.organization.id
            """)
    List<OrganizationCountProjection> countByOrganizationIds(
            @Param("organizationIds") Collection<Long> organizationIds
    );
}