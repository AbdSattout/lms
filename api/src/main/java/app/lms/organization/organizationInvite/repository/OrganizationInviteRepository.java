package app.lms.organization.organizationInvite.repository;

import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
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
    List<OrganizationInvite> findAllByUserIdAndRoleAndStatus(
            Long userId, Role role, InviteStatus status);

}
