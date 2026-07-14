package app.lms.practiceQuiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.practiceQuiz.dto.*;
import app.lms.practiceQuiz.mapper.PracticeQuizMapper;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.model.PracticeQuizAttempt;
import app.lms.practiceQuiz.model.PracticeQuizAttemptAnswer;
import app.lms.practiceQuiz.repository.PracticeQuizAttemptRepository;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;


@Service
@RequiredArgsConstructor
public class MobilePracticeQuizService {

    private final PracticeQuizRepository practiceQuizRepository;
    private final PracticeQuizAttemptRepository practiceQuizAttemptRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final PracticeQuizMapper practiceQuizMapper;
    private final QuizGradingService  quizGradingService;

    @Transactional
    public PracticeQuizPublicResponse getPracticeQuiz(
            Long courseId,
            Long practiceQuizId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findByIdAndCourseId(
                                practiceQuizId,
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice quiz not found"
                                )
                        );

        return practiceQuizMapper.toPublicResponse(
                practiceQuiz
        );
    }

    @Transactional
    public List<PracticeQuizSummaryResponse> list(
            Long courseId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        return practiceQuizRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        courseId
                )
                .stream()
                .map(practiceQuizMapper::toSummaryResponse)
                .toList();
    }
    @Transactional
    public PracticeQuizSubmitResponse submit(
            Long courseId,
            Long practiceQuizId,
            SubmitPracticeQuizRequest request,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findByIdAndCourseId(
                                practiceQuizId,
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice quiz not found"
                                )
                        );

        PracticeQuizAttempt attempt =
                PracticeQuizAttempt.builder()
                        .practiceQuiz(
                                practiceQuiz
                        )
                        .course(
                                practiceQuiz.getCourse()
                        )
                        .user(
                                user
                        )
                        .score(0)
                        .total(
                                practiceQuiz.getQuestions().size()
                        )
                        .build();

        practiceQuiz.getQuestions()
                .forEach(question -> {

                    PracticeQuizAttemptAnswer answer =
                            PracticeQuizAttemptAnswer.builder()
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

        practiceQuizAttemptRepository.save(
                attempt
        );

        return practiceQuizMapper.toSubmitResponse(
                attempt
        );
    }


}
