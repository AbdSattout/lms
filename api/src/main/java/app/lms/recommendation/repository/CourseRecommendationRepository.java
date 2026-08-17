package app.lms.recommendation.repository;

import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.enrollment.enums.EnrollmentStatus;
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
                    select new app.lms.recommendation.repository.CourseRecommendationCandidate(
                        course,
                        count(distinct popularityEnrollment.id),
                        case when count(distinct organizationMember.id) > 0 then true else false end
                    )
                    from Course course
                    join course.organization organization
                    left join CourseEnrollment popularityEnrollment
                        on popularityEnrollment.course.id = course.id
                        and popularityEnrollment.status in :countedEnrollmentStatuses
                    left join OrganizationMember organizationMember
                        on organizationMember.organization.id = organization.id
                        and organizationMember.user.id = :userId
                    where course.status = :publishedStatus
                    and not exists (
                        select enrollment.id
                        from CourseEnrollment enrollment
                        where enrollment.course.id = course.id
                        and enrollment.user.id = :userId
                    )
                    and not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = organization.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
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
                    group by course
                    order by
                        (
                            case when count(distinct organizationMember.id) > 0 then 50 else 0 end
                            + case when count(distinct popularityEnrollment.id) > 0 then 25 else 0 end
                            + case when course.createdAt >= :recentCourseCutoff then 15 else 0 end
                        ) desc,
                        count(distinct popularityEnrollment.id) desc,
                        course.createdAt desc
                    """,
            countQuery = """
                    select count(course)
                    from Course course
                    join course.organization organization
                    where course.status = :publishedStatus
                    and not exists (
                        select enrollment.id
                        from CourseEnrollment enrollment
                        where enrollment.course.id = course.id
                        and enrollment.user.id = :userId
                    )
                    and not exists (
                        select moderation.id
                        from OrganizationModeration moderation
                        where moderation.organization.id = organization.id
                        and (
                            moderation.expiresAt is null
                            or moderation.expiresAt > CURRENT_TIMESTAMP
                        )
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
    Page<CourseRecommendationCandidate> findCandidates(
            @Param("userId") Long userId,
            @Param("publishedStatus") CourseStatus publishedStatus,
            @Param("countedEnrollmentStatuses") Collection<EnrollmentStatus> countedEnrollmentStatuses,
            @Param("recentCourseCutoff") Instant recentCourseCutoff,
            Pageable pageable
    );
}
