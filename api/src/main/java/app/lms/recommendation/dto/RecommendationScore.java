package app.lms.recommendation.dto;

import app.lms.recommendation.enums.RecommendationReason;

public record RecommendationScore(
        int score,
        RecommendationReason reason
) {
}
