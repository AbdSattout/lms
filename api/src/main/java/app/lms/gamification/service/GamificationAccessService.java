package app.lms.gamification.service;

import app.lms.common.exception.ForbiddenException;
import app.lms.gamification.enums.LevelUnlockType;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class GamificationAccessService {

    private final UserProgressRepository userProgressRepository;
    private final LevelRepository levelRepository;

    @Transactional(readOnly = true)
    public List<LevelUnlockType> getUnlocks(
            User user
    ) {

        int totalXp =
                userProgressRepository
                        .findByUserId(
                                user.getId()
                        )
                        .map(UserProgress::getTotalXp)
                        .orElse(0);

        return getUnlocks(
                totalXp
        );
    }

    @Transactional(readOnly = true)
    public List<LevelUnlockType> getUnlocks(
            Integer totalXp
    ) {

        LinkedHashSet<LevelUnlockType> unlocks =
                new LinkedHashSet<>();

        levelRepository
                .findAllByRequiredXpLessThanEqualOrderByRequiredXpAsc(
                        totalXp != null
                                ? totalXp
                                : 0
                )
                .stream()
                .map(Level::getUnlockTypes)
                .filter(Objects::nonNull)
                .flatMap(List::stream)
                .forEach(unlocks::add);

        return List.copyOf(
                unlocks
        );
    }

    @Transactional(readOnly = true)
    public boolean hasUnlock(
            User user,
            LevelUnlockType unlockType
    ) {

        return getUnlocks(user)
                .contains(
                        unlockType
                );
    }

    @Transactional(readOnly = true)
    public void requireUnlock(
            User user,
            LevelUnlockType unlockType
    ) {

        if (hasUnlock(user, unlockType)) {
            return;
        }

        throw new ForbiddenException(
                "Required gamification unlock missing: " + unlockType
        );
    }
}
