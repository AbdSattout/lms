package app.lms.organization.organizationInvite.repository;

import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface OrganizationInviteRepository
        extends JpaRepository<OrganizationInvite, Long> {

    @Override
    @EntityGraph(attributePaths = {
            "organization",
            "organization.owner",
            "user",
            "invitedBy"
    })
    Optional<OrganizationInvite> findById(Long id);

    @EntityGraph(attributePaths = {
            "organization",
            "organization.owner",
            "user",
            "invitedBy"
    })
    Optional<OrganizationInvite> findByToken(String token);

    boolean existsByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            InviteStatus status
    );

    Optional<OrganizationInvite> findFirstByOrganizationIdAndUserIdOrderByCreatedAtDescIdDesc(
            Long organizationId,
            Long userId
    );

    @Query("""
            select invite
            from OrganizationInvite invite
            where invite.organization.id in :organizationIds
            and invite.user.id = :userId
            order by invite.organization.id asc, invite.createdAt desc, invite.id desc
            """)
    List<OrganizationInvite> findAllByOrganizationIdsAndUserIdOrderByLatest(
            @Param("organizationIds") Collection<Long> organizationIds,
            @Param("userId") Long userId
    );

    @EntityGraph(attributePaths = {
            "organization",
            "organization.owner",
            "user",
            "invitedBy"
    })
    List<OrganizationInvite> findAllByOrganizationIdAndStatus(
            Long organizationId,
            InviteStatus status
    );

    List<OrganizationInvite> findAllByOrganizationIdAndUserIdInAndStatus(
            Long organizationId,
            Collection<Long> userIds,
            InviteStatus status
    );

    @EntityGraph(attributePaths = {
            "organization",
            "organization.owner",
            "user",
            "invitedBy"
    })
    List<OrganizationInvite> findAllByUserIdAndRoleAndStatus(
            Long userId, Role role, InviteStatus status);

    @EntityGraph(attributePaths = {
            "organization",
            "organization.owner",
            "user",
            "invitedBy"
    })
    @Query("""
            select invite
            from OrganizationInvite invite
            where invite.user.id = :userId
            and invite.role = :role
            and invite.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = invite.organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = invite.organization.id
                and ban.user.id = :userId
                and (
                    ban.expiresAt is null
                    or ban.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    List<OrganizationInvite> findAllVisibleToUserByUserIdAndRoleAndStatus(
            @Param("userId") Long userId,
            @Param("role") Role role,
            @Param("status") InviteStatus status
    );

    void deleteByOrganizationId(Long organizationId);
}
