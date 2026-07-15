package app.lms.gamification.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.gamification.enums.LevelTier;
import lombok.Builder;
import lombok.Data;

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

    private BaseEntityResponse baseEntity;
}
