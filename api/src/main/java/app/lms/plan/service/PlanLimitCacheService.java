package app.lms.plan.service;

import app.lms.plan.enums.PlanCode;
import app.lms.plan.enums.PlanUsageType;
import app.lms.plan.model.Plan;
import app.lms.plan.model.UserPlan;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class PlanLimitCacheService {

    private static final String KEY_FORMAT =
            "plan:user:%d:limits";

    private static final String UNLIMITED =
            "unlimited";

    private static final Duration FREE_PLAN_TTL =
            Duration.ofDays(1);

    private static final Duration PREMIUM_WITHOUT_EXPIRY_TTL =
            Duration.ofMinutes(5);

    private static final Duration EXPIRED_PLAN_TTL =
            Duration.ofSeconds(1);

    private final StringRedisTemplate redisTemplate;

    public CachedPlanLimit getCachedPlanLimit(
            Long userId,
            PlanUsageType type
    ) {

        Object cachedValue =
                redisTemplate
                        .opsForHash()
                        .get(
                                key(userId),
                                field(type)
                        );

        if (cachedValue == null) {
            return CachedPlanLimit.miss();
        }

        String value =
                cachedValue.toString();

        if (UNLIMITED.equals(value)) {
            return CachedPlanLimit.hit(null);
        }

        try {
            return CachedPlanLimit.hit(
                    Integer.valueOf(value)
            );
        } catch (NumberFormatException ex) {
            evict(userId);
            return CachedPlanLimit.miss();
        }
    }

    public void cache(
            UserPlan userPlan
    ) {

        Long userId =
                userPlan.getUser()
                        .getId();

        redisTemplate
                .opsForHash()
                .putAll(
                        key(userId),
                        limits(userPlan.getPlan())
                );

        redisTemplate.expire(
                key(userId),
                ttl(userPlan)
        );
    }

    public void evict(
            Long userId
    ) {

        redisTemplate.delete(
                key(userId)
        );
    }

    private Map<String, String> limits(
            Plan plan
    ) {

        Map<String, String> limits =
                new LinkedHashMap<>();

        limits.put(
                field(PlanUsageType.AI_QUIZ),
                value(plan.getWeeklyAiQuizLimit())
        );
        limits.put(
                field(PlanUsageType.COURSE_ENROLLMENT),
                value(plan.getWeeklyCourseEnrollmentLimit())
        );
        limits.put(
                field(PlanUsageType.AI_TOOL),
                value(plan.getDailyAiToolLimit())
        );
        limits.put(
                field(PlanUsageType.RANDOM_QUIZ),
                value(plan.getRandomQuizPerCourseLimit())
        );

        return limits;
    }

    private String value(
            Integer limit
    ) {

        if (limit == null) {
            return UNLIMITED;
        }

        return limit.toString();
    }

    private Duration ttl(
            UserPlan userPlan
    ) {

        if (userPlan.getPlan()
                .getCode() != PlanCode.PREMIUM) {
            return FREE_PLAN_TTL;
        }

        if (userPlan.getExpiresAt() == null) {
            return PREMIUM_WITHOUT_EXPIRY_TTL;
        }

        Duration ttl =
                Duration.between(
                        LocalDateTime.now(),
                        userPlan.getExpiresAt()
                );

        if (ttl.isNegative() ||
                ttl.isZero()) {
            return EXPIRED_PLAN_TTL;
        }

        return ttl;
    }

    private String key(
            Long userId
    ) {

        return KEY_FORMAT.formatted(userId);
    }

    private String field(
            PlanUsageType type
    ) {

        return type.getKeySegment();
    }

    public record CachedPlanLimit(
            boolean hit,
            Integer limit
    ) {

        private static CachedPlanLimit hit(
                Integer limit
        ) {

            return new CachedPlanLimit(
                    true,
                    limit
            );
        }

        private static CachedPlanLimit miss() {

            return new CachedPlanLimit(
                    false,
                    null
            );
        }
    }
}
