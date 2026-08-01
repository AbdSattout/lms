package app.lms.roadmap.repository;

import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.model.RoadmapFollower;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RoadmapFollowerRepository
        extends JpaRepository<RoadmapFollower, Long> {

    boolean existsByRoadmapIdAndUserId(
            Long roadmapId,
            Long userId
    );

    Optional<RoadmapFollower> findByRoadmapIdAndUserId(
            Long roadmapId,
            Long userId
    );

    void deleteAllByRoadmapId(
            Long roadmapId
    );

    Page<RoadmapFollower> findAllByUserIdOrderByCreatedAtDesc(
            Long userId,
            Pageable pageable
    );

    @Query("""
            select follower
            from RoadmapFollower follower
            where follower.user.id = :userId
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id =
                        follower.roadmap.organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id =
                        follower.roadmap.organization.id
                and ban.user.id = :userId
            )
            order by follower.createdAt desc
            """)
    Page<RoadmapFollower> findAllByUserIdAndRoadmapOrganizationNotBannedOrderByCreatedAtDesc(
            @Param("userId") Long userId,
            Pageable pageable
    );

    @Query(
            """
            select count(follower)
            from RoadmapFollower follower
            where follower.user.id = :userId
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id =
                        follower.roadmap.organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id =
                        follower.roadmap.organization.id
                and ban.user.id = :userId
            )
            and (
                follower.status is null
                or follower.status <> app.lms.roadmap.enums.RoadmapFollowStatus.COMPLETED
            )
            """
    )
    long countActiveByUserId(
            @Param("userId") Long userId
    );

    long countByUserIdAndStatus(
            Long userId,
            RoadmapFollowStatus status
    );

    @Query("""
            select count(follower)
            from RoadmapFollower follower
            where follower.user.id = :userId
            and follower.status = :status
            and not exists (
                select moderation.id
                from OrganizationModeration moderation
                where moderation.organization.id =
                        follower.roadmap.organization.id
            )
            and not exists (
                select ban.id
                from OrganizationBan ban
                where ban.organization.id =
                        follower.roadmap.organization.id
                and ban.user.id = :userId
            )
            """)
    long countByUserIdAndStatusAndRoadmapOrganizationVisible(
            @Param("userId") Long userId,
            @Param("status") RoadmapFollowStatus status
    );
}
