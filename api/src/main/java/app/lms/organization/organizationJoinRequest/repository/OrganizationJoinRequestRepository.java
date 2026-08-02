package app.lms.organization.organizationJoinRequest.repository;

import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

@Repository
public interface OrganizationJoinRequestRepository extends JpaRepository<OrganizationJoinRequest, Long> {

    boolean existsByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            JoinRequestStatus status
    );

    List<OrganizationJoinRequest> findAllByOrganizationIdAndStatusOrderByCreatedAtDesc(
            Long organizationId,
            JoinRequestStatus status
    );

    Optional<OrganizationJoinRequest> findByOrganizationIdAndUserIdAndStatus(
            Long organizationId,
            Long userId,
            JoinRequestStatus status
    );

    Optional<OrganizationJoinRequest> findFirstByOrganizationIdAndUserIdOrderByCreatedAtDescIdDesc(
            Long organizationId,
            Long userId
    );

    @Query("""
            select request
            from OrganizationJoinRequest request
            where request.organization.id in :organizationIds
            and request.user.id = :userId
            order by request.organization.id asc, request.createdAt desc, request.id desc
            """)
    List<OrganizationJoinRequest> findAllByOrganizationIdsAndUserIdOrderByLatest(
            @Param("organizationIds") Collection<Long> organizationIds,
            @Param("userId") Long userId
    );

    void deleteByOrganizationId(Long organizationId);

    @Query("""
            select request
            from OrganizationJoinRequest request
            where request.user.id = :userId
            and request.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id = request.organization.id
                and (
                    moderation.expiresAt is null
                    or moderation.expiresAt > CURRENT_TIMESTAMP
                )
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id = request.organization.id
                and ban.user.id = :userId
                and (
                    ban.expiresAt is null
                    or ban.expiresAt > CURRENT_TIMESTAMP
                )
            )
            """)
    Page<OrganizationJoinRequest> findAllVisibleToUserByUserIdAndStatus(
            @Param("userId") Long userId,
            @Param("status") JoinRequestStatus status,
            Pageable pageable
    );
}
