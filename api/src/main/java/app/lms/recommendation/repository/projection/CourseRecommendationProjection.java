package app.lms.recommendation.repository.projection;

import app.lms.course.model.Course;

public interface CourseRecommendationProjection {

    Course getCourse();

    Long getEnrollmentCount();

    Boolean getUserOrganizationMember();
}