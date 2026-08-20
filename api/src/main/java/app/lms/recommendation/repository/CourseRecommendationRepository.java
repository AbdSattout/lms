package app.lms.recommendation.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.recommendation.repository.projection.CourseRecommendationProjection;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.Collection;

public interface CourseRecommendationRepository
        extends JpaRepository<Course, Long> {

    @Query(
            value = """
                    select
                        c as course,
                        count(distinct popularityEnrollment.id) as enrollmentCount,
                        case
                            when count(distinct organizationMember.id) > 0
                            then true
                            else false
                        end as userOrganizationMember
                    from Course c
                    join c.organization org
                    left join CourseEnrollment popularityEnrollment
                        on popularityEnrollment.course.id = c.id
                        and popularityEnrollment.status in :countedEnrollmentStatuses
                    left join OrganizationMember organizationMember
                        on organizationMember.organization.id = org.id
                        and organizationMember.user.id = :userId
                    where c.status = :publishedStatus
                    and not exists (
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
                    group by c
                    order by
                        (
                            case
                                when count(distinct organizationMember.id) > 0
                                then 50
                                else 0
                            end
                            +
                            case
                                when count(distinct popularityEnrollment.id) > 0
                                then 25
                                else 0
                            end
                            +
                            case
                                when c.createdAt >= :recentCourseCutoff
                                then 15
                                else 0
                            end
                        ) desc,
                        count(distinct popularityEnrollment.id) desc,
                        c.createdAt desc,
                        c.id desc
                    """,
            countQuery = """
                    select count(c)
                    from Course c
                    join c.organization org
                    where c.status = :publishedStatus
                    and not exists (
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
    Page<CourseRecommendationProjection> findCandidates(
            @Param("userId")
            Long userId,

            @Param("publishedStatus")
            CourseStatus publishedStatus,

            @Param("countedEnrollmentStatuses")
            Collection<EnrollmentStatus> countedEnrollmentStatuses,

            @Param("recentCourseCutoff")
            Instant recentCourseCutoff,

            Pageable pageable
    );
}