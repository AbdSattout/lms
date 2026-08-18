package app.lms.organization.repository;

import app.lms.organization.model.Organization;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface OrganizationRepository extends JpaRepository<Organization, Long> {

    boolean existsByNameIgnoreCase(String name);

    boolean existsBySlug(String slug);

    long countByOwnerId(Long ownerId);

    Optional<Organization> findBySlug(String slug);

    @Query("""
            select organization
            from Organization organization
            where not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    Page<Organization> findAllNotBanned(
            Pageable pageable
    );

    @Query("""
            select organization
            from Organization organization
            where not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = organization.id
                and ban.user.id = :userId
                and (
                    ban.expiresAt is null
                    or ban.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    Page<Organization> findAllVisibleToUser(
            @Param("userId") Long userId,
            Pageable pageable
    );

    @Query(
            value = """
                    select o.*
                    from organizations o
                    where
                        not exists (
                            select 1
                            from organization_moderation om
                            where om.organization_id = o.id
                            and (
                                om.expires_at is null
                                or om.expires_at > current_timestamp
                            )
                        )
                    and (
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    )
                    order by greatest(
                        similarity(o.name, :q),
                        similarity(o.slug, :q),
                        similarity(coalesce(o.description, ''), :q)
                    ) desc, o.created_at desc
                    """,
            countQuery = """
                    select count(*)
                    from organizations o
                    where
                        not exists (
                            select 1
                            from organization_moderation om
                            where om.organization_id = o.id
                            and (
                                om.expires_at is null
                                or om.expires_at > current_timestamp
                            )
                        )
                    and (
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    )
                    """,
            nativeQuery = true
    )
    Page<Organization> search(
            @Param("q") String q,
            @Param("threshold") double threshold,
            Pageable pageable
    );

    @Query(
            value = """
                    select o.*
                    from organizations o
                    where
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    order by greatest(
                        similarity(o.name, :q),
                        similarity(o.slug, :q),
                        similarity(coalesce(o.description, ''), :q)
                    ) desc, o.created_at desc
                    """,
            countQuery = """
                    select count(*)
                    from organizations o
                    where
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    """,
            nativeQuery = true
    )
    Page<Organization> searchAllForAdmin(
            @Param("q") String q,
            @Param("threshold") double threshold,
            Pageable pageable
    );

    @Query(
            value = """
                    select o.*
                    from organizations o
                    where
                        not exists (
                            select 1
                            from organization_moderation om
                            where om.organization_id = o.id
                            and (
                                om.expires_at is null
                                or om.expires_at > current_timestamp
                            )
                        )
                    and not exists (
                        select 1
                        from organization_bans ob
                        where ob.organization_id = o.id
                        and ob.user_id = :userId
                        and (
                            ob.expires_at is null
                            or ob.expires_at > current_timestamp
                        )
                    )
                    and (
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    )
                    order by greatest(
                        similarity(o.name, :q),
                        similarity(o.slug, :q),
                        similarity(coalesce(o.description, ''), :q)
                    ) desc, o.created_at desc
                    """,
            countQuery = """
                    select count(*)
                    from organizations o
                    where
                        not exists (
                            select 1
                            from organization_moderation om
                            where om.organization_id = o.id
                            and (
                                om.expires_at is null
                                or om.expires_at > current_timestamp
                            )
                        )
                    and not exists (
                        select 1
                        from organization_bans ob
                        where ob.organization_id = o.id
                        and ob.user_id = :userId
                        and (
                            ob.expires_at is null
                            or ob.expires_at > current_timestamp
                        )
                    )
                    and (
                        lower(o.name) like lower(concat('%', :q, '%'))
                        or lower(o.slug) like lower(concat('%', :q, '%'))
                        or lower(coalesce(o.description, '')) like lower(concat('%', :q, '%'))
                        or o.name % :q
                        or o.slug % :q
                        or coalesce(o.description, '') % :q
                        or similarity(o.name, :q) >= :threshold
                        or similarity(o.slug, :q) >= :threshold
                        or similarity(coalesce(o.description, ''), :q) >= :threshold
                    )
                    """,
            nativeQuery = true
    )
    Page<Organization> searchVisibleToUser(
            @Param("q") String q,
            @Param("threshold") double threshold,
            @Param("userId") Long userId,
            Pageable pageable
    );

    @Query("""
    select distinct o
    from Organization o
    join OrganizationMember m
        on m.organization.id = o.id
    where m.user.id = :userId
    and m.role in (
        app.lms.organization.enums.Role.OWNER,
        app.lms.organization.enums.Role.ADMIN
    )
    and not exists (
        select moderation.id
        from OrganizationModeration moderation
        where moderation.organization.id = o.id
        and (
            moderation.expiresAt is null
            or moderation.expiresAt > CURRENT_TIMESTAMP
        )
    )
    and not exists (
        select ban.id
        from OrganizationBan ban
        where ban.organization.id = o.id
        and ban.user.id = :userId
        and (
            ban.expiresAt is null
            or ban.expiresAt > CURRENT_TIMESTAMP
        )
    )
""")
    List<Organization> findManagedOrganizations(
            @Param("userId") Long userId
    );
}
