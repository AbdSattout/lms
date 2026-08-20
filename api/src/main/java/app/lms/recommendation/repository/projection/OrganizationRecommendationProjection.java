package app.lms.recommendation.repository.projection;

import app.lms.organization.model.Organization;

import java.time.Instant;

public interface OrganizationRecommendationProjection {

    Organization getOrganization();

    Long getPublishedCourseCount();

    Long getMemberCount();

    Long getRecentPublishedCourseCount();

    Instant getLatestPublishedCourseAt();
}