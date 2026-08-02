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

    List<OrganizationMember>
    findAllByOrganizationIdAndUserIdIn(
            Long organizationId,
            Collection<Long> userIds
    );

    @Query("""
            select member
            from OrganizationMember member
            join fetch member.user
            where member.organization.id = :organizationId
            """)
    Page<OrganizationMember> findByOrganizationId(
            @Param("organizationId") Long organizationId,
            Pageable pageable
    );

    List<OrganizationMember>
    findAllByUserId(Long userId);

    @Query("""
            select member
            from OrganizationMember member
            join fetch member.organization organization
            where member.user.id = :userId
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = organization.id
                and ban.user.id = :userId
            )
            """)
    List<OrganizationMember> findAllByUserIdAndOrganizationNotBanned(
            @Param("userId") Long userId
    );

    @Query("""
            select member
            from OrganizationMember member
            join fetch member.user
            where member.organization.id = :organizationId
            and member.role = :role
            """)
    Page<OrganizationMember> findByOrganizationIdAndRole(
            @Param("organizationId") Long organizationId,
            @Param("role") Role role,
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
            select count(member)
            from OrganizationMember member
            where member.user.id = :userId
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = member.organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = member.organization.id
                and ban.user.id = :userId
            )
            """)
    long countVisibleByUserId(
            @Param("userId") Long userId
    );

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
