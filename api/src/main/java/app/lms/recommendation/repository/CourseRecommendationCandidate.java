package app.lms.recommendation.repository;

import app.lms.course.model.Course;

public record CourseRecommendationCandidate(
        Course course,
        Long enrollmentCount,
        Boolean userOrganizationMember
) {
}
