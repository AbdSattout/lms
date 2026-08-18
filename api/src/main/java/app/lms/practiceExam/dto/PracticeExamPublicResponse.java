package app.lms.practiceExam.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.practiceExam.enums.PracticeExamStatus;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.enums.QuestionDifficulty;

import java.time.LocalDateTime;
import java.util.List;

public record PracticeExamPublicResponse(
        Long id,
        String title,
        String description,
        Integer timeLimitMinutes,
        PracticeExamStatus status,
        Long attemptId,
        LocalDateTime startedAt,
        LocalDateTime expiresAt,
        LocalDateTime serverTime,
        Long courseId,
        QuestionDifficulty difficulty,
        List<QuestionPublicResponse> questions,
        BaseEntityResponse baseEntity
) {
}
