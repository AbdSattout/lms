package app.lms.organization.repository;

import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface OrganizationMemberRepository extends JpaRepository<OrganizationMember, Long> {

    boolean existsByOrganizationIdAndUserId(
            Long organizationId,
            Long userId
    );

    Optional<OrganizationMember>
    findByOrganizationIdAndUserId(
            Long organizationId,
            Long userId
    );

    List<OrganizationMember>
    findAllByOrganizationId(Long organizationId);

    List<OrganizationMember>
    findAllByUserId(Long userId);

    List<OrganizationMember>
    findAllByOrganizationIdAndRole(
            Long organizationId,
            Role role
    );
    void deleteByOrganizationId(Long organizationId);
    List<OrganizationMember>

    findAllByUserIdAndRoleIn(
            Long userId,
            List<Role> roles
    );



}
