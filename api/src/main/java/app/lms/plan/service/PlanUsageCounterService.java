package app.lms.plan.service;

import app.lms.plan.enums.PlanUsageType;
import app.lms.plan.enums.PlanUsageWindow;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PlanUsageCounterService {

    private static final String WINDOW_KEY_FORMAT =
            "plan:user:%d:%s:%s";

    private static final String COURSE_WINDOW_KEY_FORMAT =
            "plan:user:%d:%s:course:%d:%s";

    private static final DefaultRedisScript<Long> TRY_INCREMENT_SCRIPT =
            new DefaultRedisScript<>(
                    """
                    local current = tonumber(redis.call('get', KEYS[1]) or '0')
                    local limit = tonumber(ARGV[1])

                    if current >= limit then
                        return 0
                    end

                    redis.call('incr', KEYS[1])

                    if redis.call('ttl', KEYS[1]) < 0 then
                        redis.call('expire', KEYS[1], ARGV[2])
                    end

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

    private final StringRedisTemplate redisTemplate;

    public boolean tryIncrementDaily(
            Long userId,
            PlanUsageType type,
            int limit
    ) {

        return tryIncrement(
                resolveDailyKey(
                        userId,
                        type
                ),
                limit,
                PlanUsageWindow.DAILY
        );
    }

    public boolean tryIncrementWeekly(
            Long userId,
            PlanUsageType type,
            int limit
    ) {

        return tryIncrement(
                resolveWeeklyKey(
                        userId,
                        type
                ),
                limit,
                PlanUsageWindow.WEEKLY
        );
    }

    public boolean tryIncrementCourseWeekly(
            Long userId,
            PlanUsageType type,
            Long courseId,
            int limit
    ) {

        return tryIncrement(
                resolveCourseWeeklyKey(
                        userId,
                        type,
                        courseId
                ),
                limit,
                PlanUsageWindow.WEEKLY
        );
    }

    private boolean tryIncrement(
            String key,
            int limit,
            PlanUsageWindow window
    ) {

        Long incremented =
                redisTemplate.execute(
                        TRY_INCREMENT_SCRIPT,
                        List.of(key),
                        String.valueOf(limit),
                        String.valueOf(
                                window.getDuration()
                                        .toSeconds()
                        )
                );

        return incremented != null &&
                incremented == 1;
    }

    public void releaseDaily(
            Long userId,
            PlanUsageType type
    ) {

        release(
                resolveDailyKey(
                        userId,
                        type
                )
        );
    }

    public void releaseWeekly(
            Long userId,
            PlanUsageType type
    ) {

        release(
                resolveWeeklyKey(
                        userId,
                        type
                )
        );
    }

    public void releaseCourseWeekly(
            Long userId,
            PlanUsageType type,
            Long courseId
    ) {

        release(
                resolveCourseWeeklyKey(
                        userId,
                        type,
                        courseId
                )
        );
    }

    private void release(
            String key
    ) {

        redisTemplate.execute(
                RELEASE_SCRIPT,
                List.of(key)
        );
    }

    private String resolveDailyKey(
            Long userId,
            PlanUsageType type
    ) {

        return resolveUserWindowKey(
                userId,
                type,
                PlanUsageWindow.DAILY
        );
    }

    private String resolveWeeklyKey(
            Long userId,
            PlanUsageType type
    ) {

        return resolveUserWindowKey(
                userId,
                type,
                PlanUsageWindow.WEEKLY
        );
    }

    private String resolveCourseWeeklyKey(
            Long userId,
            PlanUsageType type,
            Long courseId
    ) {

        return resolveCourseWindowKey(
                userId,
                type,
                courseId
        );
    }

    private String resolveUserWindowKey(
            Long userId,
            PlanUsageType type,
            PlanUsageWindow window
    ) {

        return WINDOW_KEY_FORMAT.formatted(
                userId,
                type.getKeySegment(),
                window.getKeySegment()
        );
    }

    private String resolveCourseWindowKey(
            Long userId,
            PlanUsageType type,
            Long courseId
    ) {

        return COURSE_WINDOW_KEY_FORMAT.formatted(
                userId,
                type.getKeySegment(),
                courseId,
                PlanUsageWindow.WEEKLY.getKeySegment()
        );
    }
}
