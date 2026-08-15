package app.lms.course.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.organization.repository.projection.OrganizationCountProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface CourseRepository
        extends JpaRepository<Course, Long> {

    List<Course> findAllByOrganizationId(
            Long organizationId
    );

    Page<Course> findAllByOrganizationId(
            Long organizationId,
            Pageable pageable
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
    @Query("""
            select course
            from Course course
            where course.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = course.organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    Page<Course> findAllByStatus(
            @Param("status") CourseStatus status,
            Pageable pageable
    );

    @Query("""
            select course
            from Course course
            where course.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = course.organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = course.organization.id
                and ban.user.id = :userId
                and (
                    ban.expiresAt is null
                    or ban.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    Page<Course> findAllByStatusVisibleToUser(
            @Param("status") CourseStatus status,
            @Param("userId") Long userId,
            Pageable pageable
    );

    @Query(
            value = """
                    select c.*
                    from courses c
                    where c.status = :status
                    and not exists (
                        select 1
                        from organization_moderation om
                        where om.organization_id = c.organization_id
                        and (
                            om.expires_at is null
                            or om.expires_at > current_timestamp
                        )
                    )
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
                    and not exists (
                        select 1
                        from organization_moderation om
                        where om.organization_id = c.organization_id
                        and (
                            om.expires_at is null
                            or om.expires_at > current_timestamp
                        )
                    )
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

    @Query(
            value = """
                    select c.*
                    from courses c
                    where c.status = :status
                    and not exists (
                        select 1
                        from organization_moderation om
                        where om.organization_id = c.organization_id
                        and (
                            om.expires_at is null
                            or om.expires_at > current_timestamp
                        )
                    )
                    and not exists (
                        select 1
                        from organization_bans ob
                        where ob.organization_id = c.organization_id
                        and ob.user_id = :userId
                        and (
                            ob.expires_at is null
                            or ob.expires_at > current_timestamp
                        )
                    )
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
                        similarity(coalesce(c.description, ''),
                                :q),
                        similarity(c.slug, :q)
                    ) desc, c.created_at desc
                    """,
            countQuery = """
                    select count(*)
                    from courses c
                    where c.status = :status
                    and not exists (
                        select 1
                        from organization_moderation om
                        where om.organization_id = c.organization_id
                        and (
                            om.expires_at is null
                            or om.expires_at > current_timestamp
                        )
                    )
                    and not exists (
                        select 1
                        from organization_bans ob
                        where ob.organization_id = c.organization_id
                        and ob.user_id = :userId
                        and (
                            ob.expires_at is null
                            or ob.expires_at > current_timestamp
                        )
                    )
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
    Page<Course> searchAllByStatusVisibleToUser(
            @Param("status") String status,
            @Param("q") String q,
            @Param("threshold") double threshold,
            @Param("userId") Long userId,
            Pageable pageable
    );

    long countByOrganizationId(Long organizationId);

    long countByOrganizationIdAndStatus(
            Long organizationId,
            CourseStatus status
    );

    @Query("""
            select course.organization.id as organizationId,
                   count(course.id) as total
            from Course course
            where course.organization.id in :organizationIds
            group by course.organization.id
            """)
    List<OrganizationCountProjection> countByOrganizationIds(
            @Param("organizationIds") Collection<Long> organizationIds
    );

    @Query("""
            select course.organization.id as organizationId,
                   count(course.id) as total
            from Course course
            where course.organization.id in :organizationIds
            and course.status = :status
            group by course.organization.id
            """)
    List<OrganizationCountProjection> countByOrganizationIdsAndStatus(
            @Param("organizationIds") Collection<Long> organizationIds,
            @Param("status") CourseStatus status
    );
}
