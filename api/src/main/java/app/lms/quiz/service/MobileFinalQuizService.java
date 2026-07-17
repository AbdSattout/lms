package app.lms.quiz.service;

import app.lms.block.repository.BlockRepository;
import app.lms.certificate.service.CertificateService;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.courceEnrollment.service.CourseEnrollmentService;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.service.GamificationService;
import app.lms.gamification.service.UserActivityService;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.quiz.dto.*;
import app.lms.quiz.mapper.QuizMapper;
import app.lms.quiz.model.FinalQuizAttempt;
import app.lms.quiz.model.FinalQuizAttemptAnswer;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.FinalQuizAttemptRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MobileFinalQuizService {

    private static final int FINAL_QUIZ_COMPLETE_XP = 100;
    private static final int COURSE_COMPLETE_XP = 200;

    private final FinalQuizAttemptRepository finalQuizAttemptRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final BlockRepository blockRepository;
    private final BlockProgressRepository blockProgressRepository;
    private final QuizGradingService quizGradingService;
    private final QuizMapper quizMapper;
    private final QuizAccessService quizAccessService;
    private final GamificationService gamificationService;
    private final UserActivityService userActivityService;
    private final CertificateService certificateService;
    private final CourseEnrollmentService courseEnrollmentService;

    @Transactional
    public FinalQuizResponse getFinalQuiz(
            Long courseId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        validateFinalQuizUnlocked(
                courseId,
                user
        );

        Quiz quiz =
                quizAccessService
                        .getAccessibleQuizByCourseId(
                                courseId,
                                user
                        );

        return quizMapper.toPublicResponse(
                quiz
        );
    }

    @Transactional
    public FinalQuizSubmitResponse submit(
            Long courseId,
            SubmitFinalQuizRequest request,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        validateFinalQuizUnlocked(
                courseId,
                user
        );

        if (
                finalQuizAttemptRepository
                        .existsByCourseIdAndUserIdAndCompletedTrue(
                                courseId,
                                user.getId()
                        )
        ) {
            throw new ConflictException(
                    "Final quiz already submitted"
            );
        }

        Quiz quiz =
                quizAccessService
                        .getAccessibleQuizByCourseId(
                                courseId,
                                user
                        );

        if (quiz.getQuestions().isEmpty()) {
            throw new ConflictException(
                    "Final quiz has no questions"
            );
        }

        FinalQuizAttempt attempt =
                FinalQuizAttempt.builder()
                        .quiz(quiz)
                        .course(quiz.getCourse())
                        .user(user)
                        .score(0)
                        .total(quiz.getQuestions().size())
                        .completed(true)
                        .build();

        quiz.getQuestions()
                .forEach(question -> {

                    FinalQuizAttemptAnswer answer =
                            FinalQuizAttemptAnswer.builder()
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

        QuizGradingResult gradingResult =
                quizGradingService.grade(
                        attempt.getAnswers(),
                        request.answers()
                );

        attempt.setScore(
                gradingResult.score()
        );

        userActivityService.recordCorrectQuestions(
                user,
                gradingResult.score()
        );

        finalQuizAttemptRepository.save(
                attempt
        );

        enrollment.setProgressPercentage(
                100
        );

        courseEnrollmentService.completeEnrollment(enrollment);

        certificateService.issueCertificate(

                quiz.getCourse(),
                user,
                attempt.getScore(),
                attempt.getTotal()
        );

        List<GamificationAwardResponse> rewards =
                new ArrayList<>();

        int earnedFinalQuizXp =
                calculateEarnedXp(
                        FINAL_QUIZ_COMPLETE_XP,
                        gradingResult
                );

        if (earnedFinalQuizXp > 0) {
            addAwardedReward(
                    rewards,
                    gamificationService.awardXp(
                            user,
                            XPEventType.FINAL_QUIZ_COMPLETE,
                            quiz.getId(),
                            earnedFinalQuizXp
                    )
            );
        }

        addAwardedReward(
                rewards,
                gamificationService.awardXp(
                        user,
                        XPEventType.COURSE_COMPLETE,
                        courseId,
                        COURSE_COMPLETE_XP
                )
        );

        return quizMapper.toSubmitResponse(
                attempt,
                rewards
        );
    }

    private void addAwardedReward(
            List<GamificationAwardResponse> rewards,
            GamificationAwardResponse reward
    ) {

        if (reward.awarded()) {
            rewards.add(reward);
        }
    }

    private int calculateEarnedXp(
            int maxXp,
            QuizGradingResult gradingResult
    ) {

        if (gradingResult.total() == null || gradingResult.total() <= 0) {
            return 0;
        }

        return maxXp * gradingResult.score() / gradingResult.total();
    }

    private void validateFinalQuizUnlocked(
            Long courseId,
            User user
    ) {

        long totalBlocks =
                blockRepository
                        .countByCourseId(
                                courseId
                        );

        long completedBlocks =
                blockProgressRepository
                        .countByUserIdAndBlockLessonChapterCourseIdAndCompletedTrue(
                                user.getId(),
                                courseId
                        );

        if (totalBlocks == 0) {
            throw new ConflictException(
                    "Course has no blocks"
            );
        }

        if (completedBlocks < totalBlocks) {
            throw new ForbiddenException(
                    "Complete all course blocks before taking the final quiz"
            );
        }
    }

}
