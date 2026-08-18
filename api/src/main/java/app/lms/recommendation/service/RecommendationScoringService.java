package app.lms.recommendation.service;

import app.lms.recommendation.dto.RecommendationScore;
import app.lms.recommendation.enums.RecommendationReason;
import app.lms.recommendation.repository.CourseRecommendationCandidate;
import app.lms.recommendation.repository.OrganizationRecommendationCandidate;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;

@Service
public class RecommendationScoringService {

    private static final int RECENT_DAYS = 30;
    private static final int JOINED_ORGANIZATION_COURSE_SCORE = 50;
    private static final int POPULAR_COURSE_SCORE = 25;
    private static final int RECENT_COURSE_SCORE = 15;
    private static final int DISCOVERABLE_COURSE_SCORE = 10;
    private static final int MANY_PUBLISHED_COURSES_SCORE = 30;
    private static final int MANY_MEMBERS_SCORE = 25;
    private static final int VERIFIED_ORGANIZATION_SCORE = 40;
    private static final int ACTIVE_ORGANIZATION_SCORE = 15;
    private static final int DISCOVERABLE_ORGANIZATION_SCORE = 10;

    public static final long MANY_PUBLISHED_COURSES_THRESHOLD = 3;
    public static final long MANY_MEMBERS_THRESHOLD = 5;

    public Instant recentCutoff() {

        return Instant.now()
                .minus(
                        RECENT_DAYS,
                        ChronoUnit.DAYS
                );
    }

    public RecommendationScore scoreCourse(
            CourseRecommendationCandidate candidate,
            Instant recentCourseCutoff
    ) {

        int score =
                DISCOVERABLE_COURSE_SCORE;

        if (Boolean.TRUE.equals(candidate.userOrganizationMember())) {
            score += JOINED_ORGANIZATION_COURSE_SCORE;
        }

        if (positive(candidate.enrollmentCount())) {
            score += POPULAR_COURSE_SCORE;
        }

        boolean recent =
                isRecent(
                        candidate.course()
                                .getCreatedAt(),
                        recentCourseCutoff
                );

        if (recent) {
            score += RECENT_COURSE_SCORE;
        }

        return new RecommendationScore(
                score,
                courseReason(
                        candidate,
                        recent
                )
        );
    }

    public RecommendationScore scoreOrganization(
            OrganizationRecommendationCandidate candidate,
            Instant recentCourseCutoff
    ) {

        int score =
                DISCOVERABLE_ORGANIZATION_SCORE;

        boolean hasManyPublishedCourses =
                atLeast(
                        candidate.publishedCourseCount(),
                        MANY_PUBLISHED_COURSES_THRESHOLD
                );

        if (hasManyPublishedCourses) {
            score += MANY_PUBLISHED_COURSES_SCORE;
        }

        boolean hasManyMembers =
                atLeast(
                        candidate.memberCount(),
                        MANY_MEMBERS_THRESHOLD
                );

        if (hasManyMembers) {
            score += MANY_MEMBERS_SCORE;
        }

        boolean verifiedOrganization =
                Boolean.TRUE.equals(
                        candidate.organization()
                                .getVerified()
                );

        if (verifiedOrganization) {
            score += VERIFIED_ORGANIZATION_SCORE;
        }

        boolean activeOrganization =
                positive(candidate.recentPublishedCourseCount())
                        || isRecent(
                                candidate.latestPublishedCourseAt(),
                                recentCourseCutoff
                        );

        if (activeOrganization) {
            score += ACTIVE_ORGANIZATION_SCORE;
        }

        return new RecommendationScore(
                score,
                organizationReason(
                        hasManyPublishedCourses,
                        hasManyMembers,
                        verifiedOrganization,
                        activeOrganization
                )
        );
    }

    private RecommendationReason courseReason(
            CourseRecommendationCandidate candidate,
            boolean recent
    ) {

        if (Boolean.TRUE.equals(candidate.userOrganizationMember())) {
            return RecommendationReason.FROM_JOINED_ORGANIZATION;
        }

        if (positive(candidate.enrollmentCount())) {
            return RecommendationReason.POPULAR_COURSE;
        }

        if (recent) {
            return RecommendationReason.RECENTLY_ADDED_COURSE;
        }

        return RecommendationReason.DISCOVERABLE_COURSE;
    }

    private RecommendationReason organizationReason(
            boolean hasManyPublishedCourses,
            boolean hasManyMembers,
            boolean verifiedOrganization,
            boolean activeOrganization
    ) {

        if (verifiedOrganization) {
            return RecommendationReason.VERIFIED_ORGANIZATION;
        }

        if (hasManyPublishedCourses) {
            return RecommendationReason.HAS_MANY_PUBLISHED_COURSES;
        }

        if (hasManyMembers) {
            return RecommendationReason.POPULAR_ORGANIZATION;
        }

        if (activeOrganization) {
            return RecommendationReason.ACTIVE_ORGANIZATION;
        }

        return RecommendationReason.DISCOVERABLE_ORGANIZATION;
    }

    private boolean positive(
            Long value
    ) {

        return value != null
                && value > 0;
    }

    private boolean atLeast(
            Long value,
            long threshold
    ) {

        return value != null
                && value >= threshold;
    }

    private boolean isRecent(
            Instant timestamp,
            Instant cutoff
    ) {

        return timestamp != null
                && cutoff != null
                && !timestamp.isBefore(cutoff);
    }
}
