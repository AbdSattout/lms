package app.lms.recommendation.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.organization.model.Organization;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;

public interface OrganizationRecommendationRepository
        extends JpaRepository<Organization, Long> {

    @Query(
            value = """
                    select new app.lms.recommendation.repository.OrganizationRecommendationCandidate(
                        organization,
                        count(distinct publishedCourse.id),
                        count(distinct member.id),
                        count(distinct recentPublishedCourse.id),
                        max(publishedCourse.createdAt)
                    )
                    from Organization organization
                    left join Course publishedCourse
                        on publishedCourse.organization.id = organization.id
                        and publishedCourse.status = :publishedStatus
                    left join Course recentPublishedCourse
                        on recentPublishedCourse.organization.id = organization.id
                        and recentPublishedCourse.status = :publishedStatus
                        and recentPublishedCourse.createdAt >= :recentCourseCutoff
                    left join OrganizationMember member
                        on member.organization.id = organization.id
                    where not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = organization.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    and not exists (
                        select organizationMember.id
                        from OrganizationMember organizationMember
                        where organizationMember.organization.id = organization.id
                        and organizationMember.user.id = :userId
                    )
                    and not exists (
                        select ban.id
                        from OrganizationBan ban
                        where ban.organization.id = organization.id
                        and ban.user.id = :userId
                        and (
                            ban.expiresAt is null
                            or ban.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    group by organization
                    order by
                        (
                            case when count(distinct publishedCourse.id) >= :manyPublishedCoursesThreshold then 30 else 0 end
                            + case when count(distinct member.id) >= :manyMembersThreshold then 25 else 0 end
                            + case when organization.verified = true then 40 else 0 end
                            + case when count(distinct recentPublishedCourse.id) > 0 then 15 else 0 end
                            + 10
                        ) desc,
                        case when organization.verified = true then 1 else 0 end desc,
                        count(distinct publishedCourse.id) desc,
                        count(distinct member.id) desc,
                        max(publishedCourse.createdAt) desc,
                        organization.createdAt desc
                    """,
            countQuery = """
                    select count(organization)
                    from Organization organization
                    where not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = organization.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    and not exists (
                        select organizationMember.id
                        from OrganizationMember organizationMember
                        where organizationMember.organization.id = organization.id
                        and organizationMember.user.id = :userId
                    )
                    and not exists (
                        select ban.id
                        from OrganizationBan ban
                        where ban.organization.id = organization.id
                        and ban.user.id = :userId
                        and (
                            ban.expiresAt is null
                            or ban.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    """
    )
    Page<OrganizationRecommendationCandidate> findCandidates(
            @Param("userId") Long userId,
            @Param("publishedStatus") CourseStatus publishedStatus,
            @Param("recentCourseCutoff") Instant recentCourseCutoff,
            @Param("manyPublishedCoursesThreshold") long manyPublishedCoursesThreshold,
            @Param("manyMembersThreshold") long manyMembersThreshold,
            Pageable pageable
    );
}
