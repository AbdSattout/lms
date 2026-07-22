package app.lms.plan.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

@Getter
@RequiredArgsConstructor
public enum PlanUsageType {
    AI_QUIZ("ai-quiz"),
    COURSE_ENROLLMENT("course-enrollment"),
    AI_TOOL("ai-tool"),
    RANDOM_QUIZ("random-quiz");

    private final String keySegment;
}
