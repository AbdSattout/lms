package app.lms.plan.service;

import app.lms.plan.enums.PlanUsageType;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.ZonedDateTime;
import java.time.temporal.TemporalAdjusters;
import java.time.temporal.WeekFields;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PlanUsageCounterService {

    private static final String WEEKLY_KEY_FORMAT =
            "plan:user:%d:%s:week:%d-W%02d";

    private static final DefaultRedisScript<Long> TRY_INCREMENT_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local current = tonumber(redis.call('get', KEYS[1]) or '0')
                    local limit = tonumber(ARGV[1])

                    if current >= limit then
                        return 0
                    end

                    redis.call('incr', KEYS[1])
                    redis.call('expire', KEYS[1], ARGV[2])

                    return 1
                    """,
                    Long.class
            );

    private static final DefaultRedisScript<Long> RELEASE_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local current = tonumber(redis.call('get', KEYS[1]) or '0')

                    if current <= 1 then
                        redis.call('del', KEYS[1])
                        return 0
                    end

                    return redis.call('decr', KEYS[1])
                    """,
                    Long.class
            );

    private static final ZoneId ZONE =
            ZoneId.systemDefault();

    private final StringRedisTemplate redisTemplate;

    public boolean tryIncrementWeekly(
            Long userId,
            PlanUsageType type,
            int limit
    ) {

        String key =
                weeklyKey(
                        userId,
                        type
                );

        Long incremented =
                redisTemplate.execute(
                        TRY_INCREMENT_SCRIPT,
                        List.of(key),
                        String.valueOf(limit),
                        String.valueOf(ttlUntilNextWeek().toSeconds())
                );

        return incremented != null &&
                incremented == 1;
    }

    public void releaseWeekly(
            Long userId,
            PlanUsageType type
    ) {

        redisTemplate.execute(
                RELEASE_SCRIPT,
                List.of(
                        weeklyKey(
                                userId,
                                type
                        )
                )
        );
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
