package app.lms.organization.repository;

import app.lms.organization.model.Organization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface OrganizationRepository extends JpaRepository<Organization, Long> {

    boolean existsByNameIgnoreCase(String name);

    boolean existsBySlug(String slug);

    Optional<Organization> findBySlug(String slug);

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
