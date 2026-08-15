package app.lms.practiceExam.service;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.badge.service.UserBadgeService;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.service.GamificationService;
import app.lms.gamification.service.UserActivityService;
import app.lms.practiceExam.dto.*;
import app.lms.practiceExam.mapper.PracticeExamMapper;
import app.lms.practiceExam.model.PracticeExam;
import app.lms.practiceExam.model.PracticeExamAttempt;
import app.lms.practiceExam.model.PracticeExamAttemptAnswer;
import app.lms.practiceExam.repository.PracticeExamAttemptRepository;
import app.lms.practiceExam.repository.PracticeExamRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MobilePracticeExamService {

    private static final int PRACTICE_EXAM_COMPLETE_XP = 40;

    private final PracticeExamRepository practiceExamRepository;
    private final PracticeExamAttemptRepository practiceExamAttemptRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final PracticeExamMapper practiceExamMapper;
    private final QuizGradingService quizGradingService;
    private final GamificationService gamificationService;
    private final UserActivityService userActivityService;
    private final UserBadgeService userBadgeService;

    @Transactional
    public PracticeExamPublicResponse getPracticeExam(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeExam practiceExam =
                getPracticeExamByCourseId(
                        courseId,
                        practiceExamId
                );

        LocalDateTime now =
                LocalDateTime.now();

        PracticeExamAttempt attempt =
                getOrCreateActiveAttempt(
                        practiceExam,
                        user,
                        now
                );

        return practiceExamMapper.toPublicResponse(
                practiceExam,
                attempt,
                now
        );
    }

    @Transactional
    public List<PracticeExamSummaryResponse> list(
            Long courseId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        return practiceExamRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        courseId
                )
                .stream()
                .map(practiceExamMapper::toSummaryResponse)
                .toList();
    }

    @Transactional
    public PracticeExamSubmitResponse submit(
            Long courseId,
            Long practiceExamId,
            SubmitPracticeExamRequest request,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeExam practiceExam =
                getPracticeExamByCourseId(
                        courseId,
                        practiceExamId
                );

        PracticeExamAttempt attempt =
                practiceExamAttemptRepository
                        .findLockedByIdAndPracticeExamIdAndCourseIdAndUserId(
                                request.attemptId(),
                                practiceExam.getId(),
                                courseId,
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice exam attempt not found"
                                )
                        );

        if (Boolean.TRUE.equals(attempt.getCompleted())) {
            throw new ConflictException(
                    "Practice exam attempt already submitted"
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        if (isExpired(attempt, now)) {
            expireAttempt(
                    attempt
            );

            throw new ConflictException(
                    "Practice exam time limit expired"
            );
        }

        QuizGradingResult gradingResult =
                quizGradingService.grade(
                        attempt.getAnswers(),
                        request.answers()
                );

        attempt.setScore(
                gradingResult.score()
        );

        attempt.setCompleted(
                true
        );

        attempt.setSubmittedAt(
                now
        );

        practiceExamAttemptRepository.save(
                attempt
        );

        int earnedXp =
                isFirstAttempt(attempt)
                        ? calculateEarnedXp(
                                gradingResult
                        )
                        : 0;

        GamificationAwardResponse reward =
                earnedXp > 0
                        ? gamificationService.awardXp(
                                user,
                                XPEventType.PRACTICE_EXAM_COMPLETE,
                                practiceExam.getId(),
                                earnedXp
                        )
                        : null;

        if (reward != null && reward.awarded()) {
            userActivityService.recordCorrectQuestions(
                    user,
                    gradingResult.score()
            );
        }

        List<UserBadgeResponse> badges =
                userBadgeService.awardEarnedBadges(user);

        return practiceExamMapper.toSubmitResponse(
                attempt,
                reward != null && reward.awarded()
                        ? List.of(reward)
                        : List.of(),
                badges
        );
    }

    private PracticeExamAttempt getOrCreateActiveAttempt(
            PracticeExam practiceExam,
            User user,
            LocalDateTime now
    ) {

        return practiceExamAttemptRepository
                .findFirstByPracticeExamIdAndCourseIdAndUserIdAndCompletedFalseOrderByStartedAtDesc(
                        practiceExam.getId(),
                        practiceExam.getCourse().getId(),
                        user.getId()
                )
                .map(attempt -> {

                    if (isExpired(
                            attempt,
                            now
                    )) {
                        expireAttempt(
                                attempt
                        );

                        return createAttempt(
                                practiceExam,
                                user,
                                now
                        );
                    }

                    return attempt;
                })
                .orElseGet(() ->
                        createAttempt(
                                practiceExam,
                                user,
                                now
                        )
                );
    }

    private PracticeExamAttempt createAttempt(
            PracticeExam practiceExam,
            User user,
            LocalDateTime now
    ) {

        PracticeExamAttempt attempt =
                PracticeExamAttempt.builder()
                        .practiceExam(
                                practiceExam
                        )
                        .course(
                                practiceExam.getCourse()
                        )
                        .user(
                                user
                        )
                        .score(0)
                        .total(
                                practiceExam.getQuestions().size()
                        )
                        .completed(false)
                        .startedAt(now)
                        .expiresAt(
                                expiresAt(
                                        practiceExam,
                                        now
                                )
                        )
                        .build();

        practiceExam.getQuestions()
                .forEach(question -> {

                    PracticeExamAttemptAnswer answer =
                            PracticeExamAttemptAnswer.builder()
                                    .attempt(
                                            attempt
                                    )
                                    .sourceQuestion(
                                            question
                                    )
                                    .content(
                                            question.getContent()
                                    )
                                    .options(
                                            new ArrayList<>(
                                                    question.getOptions()
                                            )
                                    )
                                    .correctAnswerIndex(
                                            question.getCorrectAnswerIndex()
                                    )
                                    .build();

                    attempt.getAnswers()
                            .add(
                                    answer
                            );
                });

        return practiceExamAttemptRepository.save(
                attempt
        );
    }

    private LocalDateTime expiresAt(
            PracticeExam practiceExam,
            LocalDateTime startedAt
    ) {

        if (practiceExam.getTimeLimitMinutes() == null) {
            return null;
        }

        return startedAt.plusMinutes(
                practiceExam.getTimeLimitMinutes()
        );
    }

    private boolean isExpired(
            PracticeExamAttempt attempt,
            LocalDateTime now
    ) {

        return attempt.getExpiresAt() != null
                && now.isAfter(
                        attempt.getExpiresAt()
                );
    }

    private void expireAttempt(
            PracticeExamAttempt attempt
    ) {

        attempt.setCompleted(
                true
        );

        attempt.setSubmittedAt(
                attempt.getExpiresAt()
        );
    }

    private PracticeExam getPracticeExamByCourseId(
            Long courseId,
            Long practiceExamId
    ) {

        return practiceExamRepository
                .findByIdAndCourseId(
                        practiceExamId,
                        courseId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Practice exam not found"
                        )
                );
    }

    private int calculateEarnedXp(
            QuizGradingResult gradingResult
    ) {

        if (gradingResult.total() == null || gradingResult.total() <= 0) {
            return 0;
        }

        return MobilePracticeExamService.PRACTICE_EXAM_COMPLETE_XP * gradingResult.score() / gradingResult.total();
    }

    private boolean isFirstAttempt(
            PracticeExamAttempt attempt
    ) {

        return !practiceExamAttemptRepository
                .existsByPracticeExamIdAndUserIdAndIdLessThan(
                        attempt.getPracticeExam().getId(),
                        attempt.getUser().getId(),
                        attempt.getId()
                );
    }
}
