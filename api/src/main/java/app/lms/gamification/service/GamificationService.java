package app.lms.gamification.service;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.dto.GamificationProgressResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.model.XPEvent;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.gamification.repository.XPEventRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class GamificationService {

    private final XPEventRepository xpEventRepository;
    private final UserProgressRepository userProgressRepository;
    private final LevelRepository levelRepository;
    private final UserActivityService userActivityService;

    @Transactional
    public GamificationAwardResponse awardXp(
            User user,
            XPEventType type,
            Long referenceId,
            Integer amount
    ) {

        validateAmount(amount);

        if (xpEventRepository.existsByUserIdAndTypeAndReferenceId(
                user.getId(),
                type,
                referenceId
        )) {
            return buildNoAwardResponse(
                    user,
                    type,
                    referenceId
            );
        }

        UserProgress progress =
                getOrCreateProgress(user);

        Level previousLevel =
                progress.getCurrentLevel() != null
                        ? progress.getCurrentLevel()
                        : resolveLevel(
                                progress.getTotalXp()
                        );

        XPEvent xpEvent =
                XPEvent.builder()
                        .user(user)
                        .type(type)
                        .referenceId(referenceId)
                        .amount(amount)
                        .build();

        xpEventRepository.save(xpEvent);

        int totalXp =
                progress.getTotalXp() + amount;

        Level currentLevel =
                resolveLevel(totalXp);

        progress.setTotalXp(totalXp);
        progress.setCurrentLevel(
                currentLevel
        );

        userProgressRepository.save(progress);

        userActivityService.recordAward(
                user,
                type,
                amount
        );

        return GamificationAwardResponse.builder()
                .eventType(type)
                .referenceId(referenceId)
                .awarded(true)
                .xpAwarded(amount)
                .totalXp(totalXp)
                .previousLevelNumber(
                        previousLevel != null
                                ? previousLevel.getLevelNumber()
                                : null
                )
                .currentLevelNumber(
                        currentLevel != null
                                ? currentLevel.getLevelNumber()
                                : null
                )
                .currentLevelTitle(
                        currentLevel != null
                                ? currentLevel.getTitle()
                                : null
                )
                .leveledUp(
                        didLevelUp(
                                previousLevel,
                                currentLevel
                        )
                )
                .baseEntity(
                        BaseEntityResponse.from(xpEvent)
                )
                .build();
    }

    @Transactional
    public GamificationProgressResponse getProgress(
            User user
    ) {

        UserProgress progress =
                getOrCreateProgress(user);

        Level currentLevel =
                progress.getCurrentLevel();

        if (currentLevel == null) {
            currentLevel = resolveLevel(
                    progress.getTotalXp()
            );
            progress.setCurrentLevel(currentLevel);
            userProgressRepository.save(progress);
        }

        Level nextLevel =
                levelRepository
                        .findTopByRequiredXpGreaterThanOrderByRequiredXpAsc(
                                progress.getTotalXp()
                        )
                        .orElse(null);

        return buildProgressResponse(
                progress,
                currentLevel,
                nextLevel
        );
    }

    private UserProgress getOrCreateProgress(
            User user
    ) {

        return userProgressRepository
                .findByUserId(user.getId())
                .orElseGet(() ->
                        UserProgress.builder()
                                .user(user)
                                .totalXp(0)
                                .currentLevel(
                                        levelRepository
                                                .findByLevelNumber(1)
                                                .orElse(null)
                                )
                                .build()
                );
    }

    private Level resolveLevel(
            Integer totalXp
    ) {

        return levelRepository
                .findTopByRequiredXpLessThanEqualOrderByRequiredXpDesc(
                        totalXp
                )
                .orElseGet(() ->
                        levelRepository
                                .findByLevelNumber(1)
                                .orElse(null)
                );
    }

    private GamificationAwardResponse buildNoAwardResponse(
            User user,
            XPEventType type,
            Long referenceId
    ) {

        UserProgress progress =
                getOrCreateProgress(user);

        Level currentLevel =
                progress.getCurrentLevel() != null
                        ? progress.getCurrentLevel()
                        : resolveLevel(
                                progress.getTotalXp()
                        );

        return GamificationAwardResponse.builder()
                .eventType(type)
                .referenceId(referenceId)
                .awarded(false)
                .xpAwarded(0)
                .totalXp(progress.getTotalXp())
                .previousLevelNumber(
                        currentLevel != null
                                ? currentLevel.getLevelNumber()
                                : null
                )
                .currentLevelNumber(
                        currentLevel != null
                                ? currentLevel.getLevelNumber()
                                : null
                )
                .currentLevelTitle(
                        currentLevel != null
                                ? currentLevel.getTitle()
                                : null
                )
                .leveledUp(false)
                .baseEntity(null)
                .build();
    }

    private boolean didLevelUp(
            Level previousLevel,
            Level currentLevel
    ) {

        if (previousLevel == null || currentLevel == null) {
            return false;
        }

        return currentLevel.getLevelNumber()
                > previousLevel.getLevelNumber();
    }

    private GamificationProgressResponse buildProgressResponse(
            UserProgress progress,
            Level currentLevel,
            Level nextLevel
    ) {

        int totalXp =
                progress.getTotalXp();

        int currentLevelXp =
                currentLevel != null
                        ? currentLevel.getRequiredXp()
                        : 0;

        Integer nextLevelXp =
                nextLevel != null
                        ? nextLevel.getRequiredXp()
                        : null;

        int xpIntoLevel =
                Math.max(
                        0,
                        totalXp - currentLevelXp
                );

        int xpToNextLevel =
                nextLevelXp != null
                        ? Math.max(0, nextLevelXp - totalXp)
                        : 0;

        int progressPercentage =
                calculateProgressPercentage(
                        totalXp,
                        currentLevelXp,
                        nextLevelXp
                );

        return GamificationProgressResponse.builder()
                .totalXp(totalXp)
                .levelNumber(
                        currentLevel != null
                                ? currentLevel.getLevelNumber()
                                : null
                )
                .levelTitle(
                        currentLevel != null
                                ? currentLevel.getTitle()
                                : null
                )
                .tier(
                        currentLevel != null
                                ? currentLevel.getTier()
                                : null
                )
                .currentLevelXp(currentLevelXp)
                .nextLevelXp(nextLevelXp)
                .xpIntoLevel(xpIntoLevel)
                .xpToNextLevel(xpToNextLevel)
                .progressPercentage(progressPercentage)
                .baseEntity(
                        BaseEntityResponse.from(progress)
                )
                .build();
    }

    private int calculateProgressPercentage(
            int totalXp,
            int currentLevelXp,
            Integer nextLevelXp
    ) {

        if (nextLevelXp == null) {
            return 100;
        }

        int levelRange =
                nextLevelXp - currentLevelXp;

        if (levelRange <= 0) {
            return 100;
        }

        int progress =
                totalXp - currentLevelXp;

        return (int) Math.round(
                Math.clamp(
                        progress * 1.0 / levelRange,
                        0.0,
                        1.0) * 100
        );
    }

    private void validateAmount(
            Integer amount
    ) {

        if (amount == null || amount <= 0) {
            throw new IllegalArgumentException(
                    "XP amount must be greater than zero"
            );
        }
    }
}
