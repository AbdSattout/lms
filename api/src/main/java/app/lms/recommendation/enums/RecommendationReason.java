package app.lms.recommendation.enums;

import com.fasterxml.jackson.annotation.JsonValue;

public enum RecommendationReason {

    FROM_JOINED_ORGANIZATION("From an organization you joined"),
    POPULAR_COURSE("Popular course"),
    RECENTLY_ADDED_COURSE("Recently added course"),
    DISCOVERABLE_COURSE("Course you may like"),
    RECOMMENDED_FOR_YOU("Recommended for you"),
    HAS_MANY_PUBLISHED_COURSES("Has many published courses"),
    POPULAR_ORGANIZATION("Popular organization"),
    VERIFIED_ORGANIZATION("Verified organization"),
    ACTIVE_ORGANIZATION("Active organization"),
    DISCOVERABLE_ORGANIZATION("Organization you may like");

    private final String label;

    RecommendationReason(
            String label
    ) {

        this.label = label;
    }

    @JsonValue
    public String label() {

        return label;
    }
}
