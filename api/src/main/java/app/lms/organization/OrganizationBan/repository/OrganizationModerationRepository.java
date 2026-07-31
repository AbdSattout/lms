package app.lms.organization.OrganizationBan.repository;


import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OrganizationModerationRepository
        extends JpaRepository<OrganizationModeration, Long> {
    boolean existsByOrganizationId(
            Long organizationId
    );

    Optional<OrganizationModeration> findByOrganizationId(
            Long organizationId
    );
}
