package app.lms.gamification.repository.projection;

public interface MonthlyScoreboardWinnerRow {

    Long getUserId();

    String getName();

    String getEmail();

    Long getPeriodXp();
}
