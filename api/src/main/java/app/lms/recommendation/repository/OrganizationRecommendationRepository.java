package app.lms.recommendation.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.organization.model.Organization;
import app.lms.recommendation.repository.projection.OrganizationRecommendationProjection;
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
                    select
                        org as organization,
                        count(distinct publishedCourse.id) as publishedCourseCount,
                        count(distinct member.id) as memberCount,
                        count(distinct recentPublishedCourse.id) as recentPublishedCourseCount,
                        max(publishedCourse.createdAt) as latestPublishedCourseAt
                    from Organization org
                    left join Course publishedCourse
                        on publishedCourse.organization.id = org.id
                        and publishedCourse.status = :publishedStatus
                    left join Course recentPublishedCourse
                        on recentPublishedCourse.organization.id = org.id
                        and recentPublishedCourse.status = :publishedStatus
                        and recentPublishedCourse.createdAt >= :recentCourseCutoff
                    left join OrganizationMember member
                        on member.organization.id = org.id
                    where not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = org.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    and not exists (
                        select ban.id
                        from OrganizationBan ban
                        where ban.organization.id = org.id
                        and ban.user.id = :userId
                        and (
                            ban.expiresAt is null
                            or ban.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    group by org
                    order by
                        (
                            case
                                when count(distinct publishedCourse.id)
                                    >= :manyPublishedCoursesThreshold
                                then 30
                                else 0
                            end
                            +
                            case
                                when count(distinct member.id)
                                    >= :manyMembersThreshold
                                then 25
                                else 0
                            end
                            +
                            case
                                when org.verified = true
                                then 40
                                else 0
                            end
                            +
                            case
                                when count(distinct recentPublishedCourse.id) > 0
                                then 15
                                else 0
                            end
                            + 10
                        ) desc,
                        case
                            when org.verified = true
                            then 1
                            else 0
                        end desc,
                        count(distinct publishedCourse.id) desc,
                        count(distinct member.id) desc,
                        max(publishedCourse.createdAt) desc,
                        org.createdAt desc,
                        org.id desc
                    """,

            countQuery = """
                    select count(org)
                    from Organization org
                    where not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = org.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    and not exists (
                        select ban.id
                        from OrganizationBan ban
                        where ban.organization.id = org.id
                        and ban.user.id = :userId
                        and (
                            ban.expiresAt is null
                            or ban.expiresAt > CURRENT_TIMESTAMP
                        )
                    )
                    """
    )
    Page<OrganizationRecommendationProjection> findCandidates(
            @Param("userId")
            Long userId,

            @Param("publishedStatus")
            CourseStatus publishedStatus,

            @Param("recentCourseCutoff")
            Instant recentCourseCutoff,

            @Param("manyPublishedCoursesThreshold")
            long manyPublishedCoursesThreshold,

            @Param("manyMembersThreshold")
            long manyMembersThreshold,

            Pageable pageable
    );
}