package app.lms.gamification.config;

import app.lms.gamification.enums.LevelTier;
import app.lms.gamification.enums.LevelUnlockType;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DefaultLevelSeeder implements ApplicationRunner {

    private static final int MAX_DEFAULT_LEVEL = 50;

    private final LevelRepository levelRepository;
    private final UserProgressRepository userProgressRepository;

    @Override
    @Transactional
    public void run(
            @NonNull ApplicationArguments args
    ) {

        seedLevels();
        attachMissingInitialLevels();
    }

    private void seedLevels() {

        for (int levelNumber = 1; levelNumber <= MAX_DEFAULT_LEVEL; levelNumber++) {
            if (levelRepository.existsByLevelNumber(levelNumber)) {
                continue;
            }

            Level level =
                    Level.builder()
                            .levelNumber(levelNumber)
                            .requiredXp(requiredXpFor(levelNumber))
                            .title(titleFor(levelNumber))
                            .badgeIcon(badgeIconFor(levelNumber))
                            .tier(tierFor(levelNumber))
                            .unlockTypes(unlocksFor(levelNumber))
                            .build();

            levelRepository.save(level);
        }
    }

    private void attachMissingInitialLevels() {

        Level initialLevel =
                levelRepository
                        .findByLevelNumber(1)
                        .orElse(null);

        if (initialLevel == null) {
            return;
        }

        List<UserProgress> progressRows =
                userProgressRepository.findAllByCurrentLevelIsNull();

        for (UserProgress progress : progressRows) {
            progress.setCurrentLevel(initialLevel);
        }

        userProgressRepository.saveAll(progressRows);
    }

    private int requiredXpFor(
            int levelNumber
    ) {

        if (levelNumber <= 1) {
            return 0;
        }

        return (int) Math.round(
                100 * Math.pow(levelNumber - 1, 1.5)
        );
    }

    private String titleFor(
            int levelNumber
    ) {

        return switch (tierFor(levelNumber)) {
            case BEGINNER -> "Beginner";
            case LEARNER -> "Learner";
            case EXPLORER -> "Explorer";
            case ACHIEVER -> "Achiever";
            case SPECIALIST -> "Specialist";
            case MASTER -> "Master";
        };
    }

    private String badgeIconFor(
            int levelNumber
    ) {

        return switch (tierFor(levelNumber)) {
            case BEGINNER -> "seedling";
            case LEARNER -> "book-open";
            case EXPLORER -> "compass";
            case ACHIEVER -> "trophy";
            case SPECIALIST -> "medal";
            case MASTER -> "crown";
        };
    }

    private LevelTier tierFor(
            int levelNumber
    ) {

        if (levelNumber >= 50) {
            return LevelTier.MASTER;
        }

        if (levelNumber >= 30) {
            return LevelTier.SPECIALIST;
        }

        if (levelNumber >= 20) {
            return LevelTier.ACHIEVER;
        }

        if (levelNumber >= 10) {
            return LevelTier.EXPLORER;
        }

        if (levelNumber >= 5) {
            return LevelTier.LEARNER;
        }

        return LevelTier.BEGINNER;
    }

    private List<LevelUnlockType> unlocksFor(
            int levelNumber
    ) {

        return List.of();
    }
}
