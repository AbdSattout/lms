package app.lms.organization.OrganizationBan.repository;

import app.lms.organization.OrganizationBan.model.OrganizationBan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrganizationBanRepository
        extends JpaRepository<OrganizationBan, Long> {

    boolean existsByOrganizationIdAndUserId(
            Long organizationId,
            Long userId
    );

    Optional<OrganizationBan> findByOrganizationIdAndUserId(
            Long organizationId,
            Long userId
    );


}
