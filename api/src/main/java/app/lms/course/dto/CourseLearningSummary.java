package app.lms.course.dto;

import app.lms.question.enums.QuestionDifficulty;

public record CourseLearningSummary(
        QuestionDifficulty level,
        Integer completionXp,
        Long chaptersCount
) {
}
