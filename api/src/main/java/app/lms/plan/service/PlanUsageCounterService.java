package app.lms.plan.service;

import app.lms.plan.enums.PlanUsageType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;

@Service
@RequiredArgsConstructor
public class PlanUsageCounterService {

    private static final String WEEKLY_KEY_FORMAT =
            "plan:user:%d:%s:week:%d-W%02d";

    private static final String COURSE_WEEKLY_KEY_FORMAT =
            "plan:user:%d:course:%d:%s:week:%d-W%02d";

    private static final ZoneId ZONE =
            ZoneId.systemDefault();

    private final StringRedisTemplate redisTemplate;

    public long incrementWeekly(
            Long userId,
            PlanUsageType type
    ) {

        String key =
                weeklyKey(
                        userId,
                        type
                );

        Long usage =
                redisTemplate.opsForValue()
                        .increment(key);

        redisTemplate.expire(
                key,
                ttlUntilNextWeek()
        );

        return usage != null
                ? usage
                : 0;
    }

    public long getWeeklyUsage(
            Long userId,
            PlanUsageType type
    ) {

        return getUsage(
                weeklyKey(
                        userId,
                        type
                )
        );
    }

    public long incrementCourseWeekly(
            Long userId,
            Long courseId,
            PlanUsageType type
    ) {

        String key =
                courseWeeklyKey(
                        userId,
                        courseId,
                        type
                );

        Long usage =
                redisTemplate.opsForValue()
                        .increment(key);

        redisTemplate.expire(
                key,
                ttlUntilNextWeek()
        );

        return usage != null
                ? usage
                : 0;
    }

    public long getCourseWeeklyUsage(
            Long userId,
            Long courseId,
            PlanUsageType type
    ) {

        return getUsage(
                courseWeeklyKey(
                        userId,
                        courseId,
                        type
                )
        );
    }

    private long getUsage(
            String key
    ) {

        String value =
                redisTemplate.opsForValue()
                        .get(key);

        if (value == null) {
            return 0;
        }

        return Long.parseLong(value);
    }

    private String weeklyKey(
            Long userId,
            PlanUsageType type
    ) {

        LocalDate today =
                LocalDate.now(ZONE);

        WeekFields weekFields =
                WeekFields.ISO;

        return WEEKLY_KEY_FORMAT.formatted(
                userId,
                type.getKeySegment(),
                today.get(weekFields.weekBasedYear()),
                today.get(weekFields.weekOfWeekBasedYear())
        );
    }

    private String courseWeeklyKey(
            Long userId,
            Long courseId,
            PlanUsageType type
    ) {

        LocalDate today =
                LocalDate.now(ZONE);

        WeekFields weekFields =
                WeekFields.ISO;

        return COURSE_WEEKLY_KEY_FORMAT.formatted(
                userId,
                courseId,
                type.getKeySegment(),
                today.get(weekFields.weekBasedYear()),
                today.get(weekFields.weekOfWeekBasedYear())
        );
    }

    private Duration ttlUntilNextWeek() {

        ZonedDateTime now =
                ZonedDateTime.now(ZONE);

        ZonedDateTime nextWeekStart =
                now.with(
                                TemporalAdjusters.next(
                                        DayOfWeek.MONDAY
                                )
                        )
                        .toLocalDate()
                        .atStartOfDay(ZONE);

        return Duration.between(
                now,
                nextWeekStart
        );
    }
}
