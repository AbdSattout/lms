package app.lms.recommendation.service;

import app.lms.course.model.Course;
import app.lms.organization.model.Organization;
import app.lms.recommendation.dto.RecommendationScore;
import app.lms.recommendation.enums.RecommendationReason;
import app.lms.recommendation.repository.CourseRecommendationCandidate;
import app.lms.recommendation.repository.OrganizationRecommendationCandidate;
import org.junit.jupiter.api.Test;

import java.time.Instant;

import static org.junit.jupiter.api.Assertions.assertEquals;

class RecommendationScoringServiceTest {

    private static final Instant RECENT_CUTOFF =
            Instant.parse("2026-08-01T00:00:00Z");

    private final RecommendationScoringService service =
            new RecommendationScoringService();

    @Test
    void scoresJoinedPopularRecentPublicCourse() {

        CourseRecommendationCandidate candidate =
                new CourseRecommendationCandidate(
                        courseCreatedAt(
                                RECENT_CUTOFF.plusSeconds(1)
                        ),
                        12L,
                        true,
                        true
                );

        RecommendationScore score =
                service.scoreCourse(
                        candidate,
                        RECENT_CUTOFF
                );

        assertEquals(
                100,
                score.score()
        );
        assertEquals(
                RecommendationReason.FROM_JOINED_ORGANIZATION,
                score.reason()
        );
    }

    @Test
    void usesPopularCourseReasonWhenCourseIsNotFromJoinedOrganization() {

        CourseRecommendationCandidate candidate =
                new CourseRecommendationCandidate(
                        courseCreatedAt(
                                RECENT_CUTOFF.minusSeconds(1)
                        ),
                        1L,
                        false,
                        true
                );

        RecommendationScore score =
                service.scoreCourse(
                        candidate,
                        RECENT_CUTOFF
                );

        assertEquals(
                35,
                score.score()
        );
        assertEquals(
                RecommendationReason.POPULAR_COURSE,
                score.reason()
        );
    }

    @Test
    void scoresOrganizationWithManyCoursesMembersAndRecentActivity() {

        OrganizationRecommendationCandidate candidate =
                new OrganizationRecommendationCandidate(
                        organization(),
                        4L,
                        5L,
                        1L,
                        RECENT_CUTOFF.plusSeconds(1)
                );

        RecommendationScore score =
                service.scoreOrganization(
                        candidate,
                        RECENT_CUTOFF
                );

        assertEquals(
                80,
                score.score()
        );
        assertEquals(
                RecommendationReason.HAS_MANY_PUBLISHED_COURSES,
                score.reason()
        );
    }

    @Test
    void usesActiveOrganizationReasonForRecentCourseWithoutManyCounts() {

        OrganizationRecommendationCandidate candidate =
                new OrganizationRecommendationCandidate(
                        organization(),
                        1L,
                        0L,
                        1L,
                        RECENT_CUTOFF.plusSeconds(1)
                );

        RecommendationScore score =
                service.scoreOrganization(
                        candidate,
                        RECENT_CUTOFF
                );

        assertEquals(
                25,
                score.score()
        );
        assertEquals(
                RecommendationReason.ACTIVE_ORGANIZATION,
                score.reason()
        );
    }

    private Course courseCreatedAt(
            Instant createdAt
    ) {

        Course course =
                Course.builder()
                        .build();

        course.setCreatedAt(createdAt);

        return course;
    }

    private Organization organization() {

        return Organization.builder()
                .build();
    }
}
