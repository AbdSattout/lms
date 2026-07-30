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
    Page<Organization> search(
            @Param("q") String q,
            @Param("threshold") double threshold,
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
""")
    List<Organization> findManagedOrganizations(
            Long userId
    );
}
