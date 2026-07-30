package app.lms.gamification.service;

import app.lms.gamification.dto.ScoreboardSnapshot;
import app.lms.gamification.enums.ScoreboardPeriod;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScoreboardCacheService {

    private static final String KEY_FORMAT =
            "scoreboard:%s";

    private static final ObjectMapper OBJECT_MAPPER =
            createObjectMapper();

    private final StringRedisTemplate redisTemplate;

    @Value("${app.scoreboard.cache.ttl-seconds:7200}")
    private long cacheTtlSeconds;

    public Optional<ScoreboardSnapshot> get(
            ScoreboardPeriod period
    ) {

        try {
            String json =
                    redisTemplate
                            .opsForValue()
                            .get(key(period));

            if (json == null) {
                return Optional.empty();
            }

            return Optional.of(
                    OBJECT_MAPPER.readValue(
                            json,
                            ScoreboardSnapshot.class
                    )
            );
        } catch (RuntimeException | JsonProcessingException ex) {
            log.warn(
                    "Failed to read scoreboard cache for period {}",
                    period,
                    ex
            );
            return Optional.empty();
        }
    }

    public void cache(
            ScoreboardSnapshot snapshot
    ) {

        try {
            redisTemplate
                    .opsForValue()
                    .set(
                            key(snapshot.period()),
                            OBJECT_MAPPER.writeValueAsString(snapshot),
                            cacheTtl()
                    );
        } catch (RuntimeException | JsonProcessingException ex) {
            log.warn(
                    "Failed to cache scoreboard for period {}",
                    snapshot.period(),
                    ex
            );
        }
    }

    private String key(
            ScoreboardPeriod period
    ) {

        return KEY_FORMAT.formatted(
                period.name().toLowerCase()
        );
    }

    private Duration cacheTtl() {

        return Duration.ofSeconds(cacheTtlSeconds);
    }

    private static ObjectMapper createObjectMapper() {

        return new ObjectMapper()
                .registerModule(new JavaTimeModule())
                .disable(
                        SerializationFeature.WRITE_DATES_AS_TIMESTAMPS
                );
    }
}
