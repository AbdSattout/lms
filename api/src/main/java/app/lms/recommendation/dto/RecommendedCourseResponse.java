package app.lms.recommendation.dto;

import app.lms.course.dto.CourseResponse;
import app.lms.recommendation.enums.RecommendationReason;

public record RecommendedCourseResponse(
        CourseResponse course,
        int score,
        RecommendationReason reason
) {
}
