package app.lms.gamification.service;

import app.lms.question.enums.QuestionDifficulty;

public final class LearningXpPolicy {

    public static final int EASY_BLOCK_COMPLETE_XP = 10;
    public static final int MEDIUM_BLOCK_COMPLETE_XP = 15;
    public static final int HARD_BLOCK_COMPLETE_XP = 20;
    public static final int LESSON_COMPLETE_XP = 30;
    public static final int CHAPTER_COMPLETE_XP = 75;
    public static final int FINAL_QUIZ_COMPLETE_XP = 100;
    public static final int COURSE_COMPLETE_XP = 200;

    private LearningXpPolicy() {
    }

    public static int maxBlockCompleteXpFor(
            QuestionDifficulty difficulty
    ) {

        QuestionDifficulty resolvedDifficulty =
                difficulty != null
                        ? difficulty
                        : QuestionDifficulty.MEDIUM;

        return switch (resolvedDifficulty) {
            case EASY -> EASY_BLOCK_COMPLETE_XP;
            case MEDIUM -> MEDIUM_BLOCK_COMPLETE_XP;
            case HARD -> HARD_BLOCK_COMPLETE_XP;
        };
    }
}
