package app.lms.recommendation.dto;

import app.lms.organization.dto.OrganizationResponse;
import app.lms.recommendation.enums.RecommendationReason;

public record RecommendedOrganizationResponse(
        OrganizationResponse organization,
        int score,
        RecommendationReason reason
) {
}
