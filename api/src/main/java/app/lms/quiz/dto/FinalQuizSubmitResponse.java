package app.lms.quiz.dto;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.certificate.dto.CertificateResponse;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.gamification.dto.GamificationAwardResponse;

import java.util.List;

public record FinalQuizSubmitResponse(

        Long attemptId,

        Integer score,

        Integer total,

        List<FinalQuizQuestionResultResponse> results,

        List<GamificationAwardResponse> rewards,

        CertificateResponse certificate,

        List<UserBadgeResponse> badges,

        BaseEntityResponse baseEntity
) {
}
