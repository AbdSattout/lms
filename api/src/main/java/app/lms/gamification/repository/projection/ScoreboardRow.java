package app.lms.gamification.repository.projection;

public interface ScoreboardRow {

    Long getUserId();

    String getName();

    String getPicture();

    Long getPeriodXp();

    Integer getLevelNumber();

    String getLevelTitle();
}
