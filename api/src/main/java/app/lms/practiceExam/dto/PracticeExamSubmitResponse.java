package app.lms.practiceExam.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.gamification.dto.GamificationAwardResponse;

import java.util.List;

public record PracticeExamSubmitResponse(
        Long attemptId,
        Integer score,
        Integer total,
        List<PracticeExamQuestionResultResponse> results,
        List<GamificationAwardResponse> rewards,
        BaseEntityResponse baseEntity
) {
}
