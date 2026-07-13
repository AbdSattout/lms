package app.lms.randomquiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizAttemptValidationService;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import app.lms.question.repository.QuestionRepository;
import app.lms.randomquiz.dto.*;
import app.lms.randomquiz.mapper.BankRandomQuizMapper;
import app.lms.randomquiz.model.BankRandomQuizAttempt;
import app.lms.randomquiz.model.BankRandomQuizAttemptQuestion;
import app.lms.randomquiz.repository.BankRandomQuizAttemptRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@RequiredArgsConstructor
public class BankRandomQuizService {

    private static final int DEFAULT_QUIZ_SIZE = 10;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final QuestionRepository questionRepository;
    private final BankRandomQuizAttemptRepository bankRandomQuizAttemptRepository;
    private final QuizGradingService quizGradingService;
    private final QuizAttemptValidationService quizAttemptValidationService;
    private final BankRandomQuizMapper bankRandomQuizMapper;

    @Transactional
    public BankRandomQuizResponse generate(
            Long courseId,
            GenerateBankRandomQuizRequest request,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        int count =
                request.count() != null
                        ? request.count()
                        : DEFAULT_QUIZ_SIZE;

        List<Question> selectedQuestions =
                selectRandomQuestions(
                        courseId,
                        request.difficulty(),
                        count
                );

        BankRandomQuizAttempt attempt =
                BankRandomQuizAttempt.builder()
                        .course(
                                enrollment.getCourse()
                        )
                        .user(
                                user
                        )
                        .difficulty(
                                request.difficulty()
                        )
                        .completed(false)
                        .build();

        for (Question question : selectedQuestions) {

            BankRandomQuizAttemptQuestion attemptQuestion =
                    BankRandomQuizAttemptQuestion.builder()
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

            attempt.getQuestions()
                    .add(
                            attemptQuestion
                    );
        }

        bankRandomQuizAttemptRepository.save(
                attempt
        );

        return bankRandomQuizMapper.toResponse(
                attempt
        );
    }

    @Transactional
    public BankRandomQuizSubmitResponse submit(
            Long courseId,
            Long attemptId,
            SubmitBankRandomQuizRequest request,
            User user
    ) {

        courseEnrollmentAccessService
                .getEnrollment(
                        courseId,
                        user
                );

        BankRandomQuizAttempt attempt =
                bankRandomQuizAttemptRepository
                        .findByIdAndCourseIdAndUserId(
                                attemptId,
                                courseId,
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Random quiz attempt not found"
                                )
                        );

        quizAttemptValidationService.validateNotSubmitted(
                attempt
        );

        QuizGradingResult gradingResult =
                quizGradingService.grade(
                        attempt.getQuestions(),
                        request.answers()
                );

        attempt.setScore(
                gradingResult.score()
        );

        attempt.setCompleted(
                true
        );

        return bankRandomQuizMapper.toSubmitResponse(
                attempt
        );
    }

    private List<Question> selectRandomQuestions(
            Long courseId,
            QuestionDifficulty requestedDifficulty,
            int count
    ) {

        Map<QuestionDifficulty, List<Question>> pools =
                new EnumMap<>(
                        QuestionDifficulty.class
                );

        for (QuestionDifficulty difficulty : QuestionDifficulty.values()) {

            List<Question> questions =
                    new ArrayList<>(
                            questionRepository
                                    .findAllByCourseIdAndDifficulty(
                                            courseId,
                                            difficulty
                                    )
                    );

            Collections.shuffle(
                    questions
            );

            pools.put(
                    difficulty,
                    questions
            );
        }

        int totalAvailable =
                pools.values()
                        .stream()
                        .mapToInt(
                                List::size
                        )
                        .sum();

        if (totalAvailable < count) {
            throw new BadRequestException(
                    "Not enough questions in the question bank for this quiz"
            );
        }

        List<Question> selected =
                new ArrayList<>(takeQuestions(
                        pools.get(requestedDifficulty),
                        count
                ));

        while (selected.size() < count) {

            boolean added = false;

            for (QuestionDifficulty fallbackDifficulty :
                    getFallbackOrder(requestedDifficulty)) {

                if (selected.size() == count) {
                    break;
                }

                List<Question> pool =
                        pools.get(
                                fallbackDifficulty
                        );

                if (!pool.isEmpty()) {
                    selected.add(
                            pool.removeFirst()
                    );

                    added = true;
                }
            }

            if (!added) {
                break;
            }
        }

        Collections.shuffle(
                selected
        );

        return selected;
    }

    private List<Question> takeQuestions(
            List<Question> source,
            int count
    ) {

        int takeCount =
                Math.min(
                        count,
                        source.size()
                );

        List<Question> result =
                new ArrayList<>(
                        source.subList(
                                0,
                                takeCount
                        )
                );

        source.subList(
                0,
                takeCount
        ).clear();

        return result;
    }

    private List<QuestionDifficulty> getFallbackOrder(
            QuestionDifficulty requestedDifficulty
    ) {

        return switch (requestedDifficulty) {

            case EASY -> List.of(
                    QuestionDifficulty.MEDIUM,
                    QuestionDifficulty.HARD
            );

            case MEDIUM -> List.of(
                    QuestionDifficulty.HARD,
                    QuestionDifficulty.EASY
            );

            case HARD -> List.of(
                    QuestionDifficulty.MEDIUM,
                    QuestionDifficulty.EASY
            );
        };
    }

}
