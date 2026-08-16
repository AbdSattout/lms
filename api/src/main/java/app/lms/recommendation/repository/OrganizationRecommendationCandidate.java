package app.lms.recommendation.repository;

import app.lms.organization.model.Organization;

import java.time.Instant;

public record OrganizationRecommendationCandidate(
        Organization organization,
        Long publishedCourseCount,
        Long memberCount,
        Long recentPublishedCourseCount,
        Instant latestPublishedCourseAt
) {
}
