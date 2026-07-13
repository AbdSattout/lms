package app.lms.practiceQuiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.practiceQuiz.dto.*;
import app.lms.practiceQuiz.mapper.PracticeQuizMapper;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.model.PracticeQuizAttempt;
import app.lms.practiceQuiz.model.PracticeQuizAttemptAnswer;
import app.lms.practiceQuiz.repository.PracticeQuizAttemptRepository;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.question.model.Question;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MobilePracticeQuizService {

    private final PracticeQuizRepository practiceQuizRepository;
    private final PracticeQuizAttemptRepository practiceQuizAttemptRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final PracticeQuizMapper practiceQuizMapper;

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
                .map(practiceQuiz ->
                        new PracticeQuizSummaryResponse(
                                practiceQuiz.getId(),
                                practiceQuiz.getTitle(),
                                practiceQuiz.getDescription(),
                                practiceQuiz.getCourse().getId(),
                                practiceQuiz.getQuestions().size()
                        )
                )
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

        if (request.answers().size() != practiceQuiz.getQuestions().size()) {
            throw new BadRequestException(
                    "You must answer all practice quiz questions"
            );
        }

        Map<Long, Integer> answers =
                request.answers()
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        SubmitPracticeQuizAnswer::questionId,
                                        SubmitPracticeQuizAnswer::answerIndex,
                                        (_, _) -> {
                                            throw new BadRequestException(
                                                    "Duplicate question answer"
                                            );
                                        }
                                )
                        );

        PracticeQuizAttempt attempt =
                PracticeQuizAttempt.builder()
                        .practiceQuiz(practiceQuiz)
                        .course(practiceQuiz.getCourse())
                        .user(user)
                        .score(0)
                        .total(practiceQuiz.getQuestions().size())
                        .build();

        int score = 0;

        for (Question question : practiceQuiz.getQuestions()) {

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

            PracticeQuizAttemptAnswer answer =
                    PracticeQuizAttemptAnswer.builder()
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

        practiceQuizAttemptRepository.save(
                attempt
        );

        return practiceQuizMapper.toSubmitResponse(
                attempt
        );
    }


}