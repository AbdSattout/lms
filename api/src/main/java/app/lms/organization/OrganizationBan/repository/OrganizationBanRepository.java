package app.lms.organization.OrganizationBan.repository;

import app.lms.organization.OrganizationBan.model.OrganizationBan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface OrganizationBanRepository
        extends JpaRepository<OrganizationBan, Long> {

    @Query("""
            select case when count(ban) > 0 then true else false end
            from OrganizationBan ban
            where ban.organization.id = :organizationId
            and ban.user.id = :userId
            and (
                ban.expiresAt is null
                or ban.expiresAt > CURRENT_TIMESTAMP
            )
            """)
    boolean existsActiveByOrganizationIdAndUserId(
            @Param("organizationId") Long organizationId,
            @Param("userId") Long userId
    );

    Optional<OrganizationBan> findByOrganizationIdAndUserId(
            Long organizationId,
            Long userId
    );


}
