package app.lms.organization.repository;

import app.lms.organization.enums.InviteStatus;
import app.lms.organization.model.OrganizationInvite;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrganizationInviteRepository
        extends JpaRepository<OrganizationInvite, Long> {

    Optional<OrganizationInvite> findByToken(String token);

    boolean existsByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            InviteStatus status
    );

    List<OrganizationInvite> findAllByOrganizationIdAndStatus(
            Long organizationId,
            InviteStatus status
    );

}
