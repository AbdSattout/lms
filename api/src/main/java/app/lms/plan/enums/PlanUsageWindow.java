package app.lms.plan.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

import java.time.Duration;

@Getter
@RequiredArgsConstructor
public enum PlanUsageWindow {
    DAILY(
            "day",
            Duration.ofDays(1)
    ),
    WEEKLY(
            "week",
            Duration.ofDays(7)
    );

    private final String keySegment;
    private final Duration duration;
}
