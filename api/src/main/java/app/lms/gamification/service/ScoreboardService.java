package app.lms.gamification.service;

import app.lms.gamification.dto.ScoreboardEntryResponse;
import app.lms.gamification.dto.ScoreboardResponse;
import app.lms.gamification.dto.ScoreboardSnapshot;
import app.lms.gamification.enums.ScoreboardPeriod;
import app.lms.gamification.repository.UserActivityDayRepository;
import app.lms.gamification.repository.projection.ScoreboardRow;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.temporal.TemporalAdjusters;
import java.util.List;
import java.util.Optional;
import java.util.stream.IntStream;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScoreboardService {

    private static final int DEFAULT_LIMIT = 50;
    private static final int MAX_LIMIT = 100;

    private final UserActivityDayRepository userActivityDayRepository;
    private final ScoreboardCacheService scoreboardCacheService;

    @Scheduled(
            fixedDelayString = "${app.scoreboard.refresh-scheduler.fixed-delay-ms:300000}",
            initialDelayString = "${app.scoreboard.refresh-scheduler.initial-delay-ms:60000}"
    )
    public void refreshCachedScoreboards() {

        for (ScoreboardPeriod period : ScoreboardPeriod.values()) {
            ScoreboardSnapshot snapshot =
                    refreshScoreboard(period);

            log.info(
                    "Refreshed {} scoreboard with {} ranked user(s)",
                    period,
                    snapshot.rankedEntries().size()
            );
        }
    }

    public ScoreboardResponse getScoreboard(
            User user,
            ScoreboardPeriod period,
            Integer limit
    ) {

        ScoreboardPeriod resolvedPeriod =
                period != null
                        ? period
                        : ScoreboardPeriod.WEEKLY;

        int resolvedLimit =
                resolveLimit(limit);

        LocalDateRange range =
                resolveRange(resolvedPeriod);

        List<ScoreboardEntryResponse> rankedEntries =
                rankedEntries(
                        resolvedPeriod,
                        range
                );

        List<ScoreboardEntryResponse> leaders =
                rankedEntries.stream()
                        .limit(resolvedLimit)
                        .toList();

        ScoreboardEntryResponse me =
                resolveCurrentUserEntry(
                        user,
                        rankedEntries
                );

        return ScoreboardResponse.builder()
                .period(resolvedPeriod)
                .from(range.from())
                .to(range.to())
                .leaders(leaders)
                .me(me)
                .build();
    }

    private List<ScoreboardEntryResponse> rankedEntries(
            ScoreboardPeriod period,
            LocalDateRange range
    ) {

        return scoreboardCacheService
                .get(period)
                .filter(snapshot ->
                        snapshot.matches(
                                range.from(),
                                range.to()
                        )
                )
                .map(ScoreboardSnapshot::rankedEntries)
                .orElseGet(() ->
                        refreshScoreboard(period)
                                .rankedEntries()
                );
    }

    private ScoreboardSnapshot refreshScoreboard(
            ScoreboardPeriod period
    ) {

        LocalDateRange range =
                resolveRange(period);

        List<ScoreboardRow> rows =
                userActivityDayRepository.findScoreboardRows(
                        range.from(),
                        range.to()
                );

        List<ScoreboardEntryResponse> rankedEntries =
                IntStream.range(0, rows.size())
                        .mapToObj(index ->
                                toEntry(
                                        index + 1,
                                        rows.get(index)
                                )
                        )
                        .toList();

        ScoreboardSnapshot snapshot =
                new ScoreboardSnapshot(
                        period,
                        range.from(),
                        range.to(),
                        rankedEntries
                );

        scoreboardCacheService.cache(snapshot);

        return snapshot;
    }

    private int resolveLimit(
            Integer limit
    ) {

        if (limit == null) {
            return DEFAULT_LIMIT;
        }

        return Math.clamp(
                limit,
                1,
                MAX_LIMIT
        );
    }

    private LocalDateRange resolveRange(
            ScoreboardPeriod period
    ) {

        LocalDate today =
                LocalDate.now();

        return switch (period) {
            case WEEKLY ->
                    new LocalDateRange(
                            today.with(
                                    TemporalAdjusters.previousOrSame(
                                            DayOfWeek.SATURDAY
                                    )
                            ),
                            today.with(
                                    TemporalAdjusters.nextOrSame(
                                            DayOfWeek.FRIDAY
                                    )
                            )
                    );
            case MONTHLY ->
                    new LocalDateRange(
                            today.withDayOfMonth(1),
                            today.with(
                                    TemporalAdjusters.lastDayOfMonth()
                            )
                    );
        };
    }

    private ScoreboardEntryResponse resolveCurrentUserEntry(
            User user,
            List<ScoreboardEntryResponse> rankedEntries
    ) {

        Optional<ScoreboardEntryResponse> entry =
                rankedEntries.stream()
                        .filter(candidate ->
                                candidate.userId()
                                        .equals(
                                                user.getId()
                                        )
                        )
                        .findFirst();

        return entry.orElseGet(() ->
                ScoreboardEntryResponse.builder()
                        .rank(null)
                        .userId(user.getId())
                        .name(user.getName())
                        .picture(user.getPicture())
                        .xp(0L)
                        .levelNumber(null)
                        .levelTitle(null)
                        .build()
        );
    }

    private ScoreboardEntryResponse toEntry(
            int rank,
            ScoreboardRow row
    ) {

        return ScoreboardEntryResponse.builder()
                .rank(rank)
                .userId(row.getUserId())
                .name(row.getName())
                .picture(row.getPicture())
                .xp(row.getPeriodXp())
                .levelNumber(row.getLevelNumber())
                .levelTitle(row.getLevelTitle())
                .build();
    }

    private record LocalDateRange(
            LocalDate from,
            LocalDate to
    ) {
    }
}
