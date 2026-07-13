package app.lms.quiz.service;

import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.model.Question;
import app.lms.quiz.dto.*;
import app.lms.quiz.model.FinalQuizAttempt;
import app.lms.quiz.model.FinalQuizAttemptAnswer;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.FinalQuizAttemptRepository;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MobileFinalQuizService {

    private final QuizRepository quizRepository;
    private final FinalQuizAttemptRepository finalQuizAttemptRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final BlockRepository blockRepository;
    private final BlockProgressRepository blockProgressRepository;

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
                quizRepository
                        .findByCourseId(
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Final quiz not found"
                                )
                        );

        return new FinalQuizResponse(
                quiz.getId(),
                courseId,
                quiz.getQuestions()
                        .stream()
                        .map(question ->
                                new QuestionPublicResponse(
                                        question.getId(),
                                        question.getContent(),
                                        question.getOptions()
                                )
                        )
                        .toList()
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
                quizRepository
                        .findByCourseId(
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Final quiz not found"
                                )
                        );

        if (quiz.getQuestions().isEmpty()) {
            throw new ConflictException(
                    "Final quiz has no questions"
            );
        }

        if (
                request.answers().size()
                        != quiz.getQuestions().size()
        ) {
            throw new BadRequestException(
                    "You must answer all quiz questions"
            );
        }

        long distinctAnswerCount =
                request.answers()
                        .stream()
                        .map(
                                SubmitFinalQuizAnswer::questionId
                        )
                        .distinct()
                        .count();

        if (distinctAnswerCount != request.answers().size()) {
            throw new BadRequestException(
                    "Duplicate question answer"
            );
        }

        Map<Long, Integer> answers =
                request.answers()
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        SubmitFinalQuizAnswer::questionId,
                                        SubmitFinalQuizAnswer::answerIndex
                                )
                        );


        FinalQuizAttempt attempt =
                FinalQuizAttempt.builder()
                        .quiz(quiz)
                        .course(quiz.getCourse())
                        .user(user)
                        .score(0)
                        .total(quiz.getQuestions().size())
                        .completed(true)
                        .build();

        int score = 0;

        for (Question question : quiz.getQuestions()) {

            Integer selectedAnswerIndex =
                    answers.get(
                            question.getId()
                    );

            if (selectedAnswerIndex == null) {
                throw new BadRequestException(
                        "Missing answer for question: " + question.getId()
                );
            }

            if (
                    selectedAnswerIndex < 0
                            ||
                            selectedAnswerIndex >= question.getOptions().size()
            ) {
                throw new BadRequestException(
                        "Invalid answer index for question: " + question.getId()
                );
            }

            boolean correct =
                    question.getCorrectAnswerIndex()
                            .equals(
                                    selectedAnswerIndex
                            );

            if (correct) {
                score++;
            }

            FinalQuizAttemptAnswer answer =
                    FinalQuizAttemptAnswer.builder()
                            .attempt(attempt)
                            .sourceQuestion(question)
                            .content(question.getContent())
                            .options(
                                    new ArrayList<>(
                                            question.getOptions()
                                    )
                            )
                            .correctAnswerIndex(
                                    question.getCorrectAnswerIndex()
                            )
                            .selectedAnswerIndex(
                                    selectedAnswerIndex
                            )
                            .correct(correct)
                            .build();

            attempt.getAnswers()
                    .add(
                            answer
                    );
        }

        attempt.setScore(
                score
        );

        finalQuizAttemptRepository.save(
                attempt
        );

        enrollment.setProgressPercentage(
                100
        );

        if (enrollment.getCompletedAt() == null) {
            enrollment.setCompletedAt(
                    LocalDateTime.now()
            );
        }

        return toSubmitResponse(
                attempt
        );
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

    private FinalQuizSubmitResponse toSubmitResponse(
            FinalQuizAttempt attempt
    ) {

        return new FinalQuizSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getTotal(),
                attempt.getAnswers()
                        .stream()
                        .map(answer ->
                                new FinalQuizQuestionResultResponse(
                                        answer.getSourceQuestion()
                                                .getId(),
                                        answer.getContent(),
                                        answer.getOptions(),
                                        answer.getSelectedAnswerIndex(),
                                        answer.getCorrectAnswerIndex(),
                                        answer.getCorrect()
                                )
                        )
                        .toList()
        );
    }
}