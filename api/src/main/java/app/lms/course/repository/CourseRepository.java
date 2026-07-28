package app.lms.course.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    Page<Course> findAllByOrganizationId(
            Long organizationId,
            Pageable pageable
    );


    List<Course> findAllByOrganizationId(
            Long organizationId
    );
    Page<Course> findAllByOrganizationIdAndStatus(
            Long organizationId,
            CourseStatus status,
            Pageable pageable
    );

    boolean existsByOrganizationIdAndSlug(
            Long organizationId,
            String slug
    );

    Optional<Course> findByOrganizationIdAndSlug(
            Long organizationId,
            String slug
    );
    Page<Course> findAllByStatus(
            CourseStatus status,
            Pageable pageable
    );

    @Query(
            value = """
                    select c.*
                    from courses c
                    where c.status = :status
                    and (
                        lower(c.title) like lower(concat('%', :q, '%'))
                        or lower(coalesce(c.description, '')) like lower(concat('%', :q, '%'))
                        or lower(c.slug) like lower(concat('%', :q, '%'))
                        or c.title % :q
                        or coalesce(c.description, '') % :q
                        or c.slug % :q
                        or similarity(c.title, :q) >= :threshold
                        or similarity(coalesce(c.description, ''), :q) >= :threshold
                        or similarity(c.slug, :q) >= :threshold
                    )
                    order by greatest(
                        similarity(c.title, :q),
                        similarity(coalesce(c.description, ''), :q),
                        similarity(c.slug, :q)
                    ) desc, c.created_at desc
                    """,
            countQuery = """
                    select count(*)
                    from courses c
                    where c.status = :status
                    and (
                        lower(c.title) like lower(concat('%', :q, '%'))
                        or lower(coalesce(c.description, '')) like lower(concat('%', :q, '%'))
                        or lower(c.slug) like lower(concat('%', :q, '%'))
                        or c.title % :q
                        or coalesce(c.description, '') % :q
                        or c.slug % :q
                        or similarity(c.title, :q) >= :threshold
                        or similarity(coalesce(c.description, ''), :q) >= :threshold
                        or similarity(c.slug, :q) >= :threshold
                    )
                    """,
            nativeQuery = true
    )
    Page<Course> searchAllByStatus(
            @Param("status") String status,
            @Param("q") String q,
            @Param("threshold") double threshold,
            Pageable pageable
    );

    long countByOrganizationId(Long organizationId);

    long countByOrganizationIdAndStatus(
            Long organizationId,
            CourseStatus status
    );
}
