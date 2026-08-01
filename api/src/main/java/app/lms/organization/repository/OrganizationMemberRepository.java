package app.lms.organization.repository;

import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.projection.OrganizationCountProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
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
    @Query("""
select m
from OrganizationMember m
join fetch m.user
where m.organization.id = :organizationId
""")    Page<OrganizationMember> findByOrganizationId(
            Long organizationId,
            Pageable pageable
    );

    List<OrganizationMember>
    findAllByUserId(Long userId);

    Page<OrganizationMember> findByOrganizationIdAndRole(
            Long organizationId,
            Role role,
            Pageable pageable
    );
    void deleteByOrganizationId(Long organizationId);
    List<OrganizationMember>

    findAllByUserIdAndRoleIn(
            Long userId,
            List<Role> roles
    );

    long countByOrganizationId(Long organizationId);

    long countByOrganizationIdAndRole(
            Long organizationId,
            Role role
    );

    long countByUserId(Long userId);

    @Query("""
            select member.organization.id as organizationId,
                   count(member.id) as total
            from OrganizationMember member
            where member.organization.id in :organizationIds
            group by member.organization.id
            """)
    List<OrganizationCountProjection> countByOrganizationIds(
            @Param("organizationIds") Collection<Long> organizationIds
    );

    @Query("""
            select member.organization.id as organizationId,
                   count(member.id) as total
            from OrganizationMember member
            where member.organization.id in :organizationIds
            and member.role = :role
            group by member.organization.id
            """)
    List<OrganizationCountProjection> countByOrganizationIdsAndRole(
            @Param("organizationIds") Collection<Long> organizationIds,
            @Param("role") Role role
    );
}
