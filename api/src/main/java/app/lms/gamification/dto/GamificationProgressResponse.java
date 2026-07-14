package app.lms.gamification.dto;

import app.lms.gamification.enums.LevelTier;
import app.lms.gamification.enums.LevelUnlockType;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class GamificationProgressResponse {

    private Integer totalXp;

    private Integer levelNumber;

    private String levelTitle;

    private LevelTier tier;

    private Integer currentLevelXp;

    private Integer nextLevelXp;

    private Integer xpIntoLevel;

    private Integer xpToNextLevel;

    private Integer progressPercentage;

    private String badgeIcon;

    private List<LevelUnlockType> unlocks;
}
