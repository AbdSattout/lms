package app.lms.organization.OrganizationBan.repository;


import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface OrganizationModerationRepository
        extends JpaRepository<OrganizationModeration, Long> {

    @Query("""
            select case when count(moderation) > 0 then true else false end
            from OrganizationModeration moderation
            where moderation.organization.id = :organizationId
            and (
                moderation.expiresAt is null
                or moderation.expiresAt > CURRENT_TIMESTAMP
            )
            """)
    boolean existsActiveByOrganizationId(
            @Param("organizationId") Long organizationId
    );

    Optional<OrganizationModeration> findByOrganizationId(
            Long organizationId
    );

    @Query(
            value = """
                    select moderation
                    from OrganizationModeration moderation
                    join fetch moderation.organization
                    join fetch moderation.bannedBy
                    where moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                    """,
            countQuery = """
                    select count(moderation)
                    from OrganizationModeration moderation
                    where moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                    """
    )
    Page<OrganizationModeration> findAllActive(
            Pageable pageable
    );
}
