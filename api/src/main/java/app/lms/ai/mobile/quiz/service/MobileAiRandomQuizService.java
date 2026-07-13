package app.lms.ai.mobile.quiz.service;

import app.lms.ai.common.exception.AiServiceException;
import app.lms.ai.mobile.quiz.dto.*;
import app.lms.ai.mobile.quiz.mapper.MobileAiRandomQuizMapper;
import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import app.lms.ai.mobile.quiz.model.RandomQuizAttemptQuestion;
import app.lms.ai.mobile.quiz.repository.RandomQuizAttemptRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizAttemptValidationService;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.question.model.Question;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class MobileAiRandomQuizService {

    private static final int RANDOM_QUIZ_SIZE = 10;

    private final ChatClient.Builder chatClientBuilder;
    private final MobileAiRandomQuizPromptService promptService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final BlockProgressRepository blockProgressRepository;
    private final RandomQuizAttemptRepository randomQuizAttemptRepository;
    private final QuizGradingService quizGradingService;
    private final QuizAttemptValidationService quizAttemptValidationService;
    private final MobileAiRandomQuizMapper mobileAiRandomQuizMapper;
    @Transactional
    public RandomQuizResponse generate(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        List<Question> completedQuestions =
                blockProgressRepository
                        .findCompletedQuestionsByUserAndCourse(
                                user.getId(),
                                courseId
                        );

        if (completedQuestions.size() < RANDOM_QUIZ_SIZE) {
            throw new BadRequestException(
                    "You need to complete at least 10 questions before generating a random quiz"
            );
        }

        Collections.shuffle(
                completedQuestions
        );

        List<Question> selectedQuestions =
                completedQuestions
                        .stream()
                        .limit(RANDOM_QUIZ_SIZE)
                        .toList();

        try {

            ChatClient chatClient =
                    chatClientBuilder.build();

            GeneratedRandomQuizResponse aiResponse =
                    chatClient
                            .prompt()
                            .system(
                                    promptService.systemPrompt()
                            )
                            .user(
                                    promptService.buildPrompt(
                                            selectedQuestions
                                    )
                            )
                            .call()
                            .entity(
                                    GeneratedRandomQuizResponse.class
                            );

            validateAiResponse(
                    aiResponse,
                    selectedQuestions
            );

            RandomQuizAttempt attempt =
                    buildAttempt(
                            enrollment,
                            selectedQuestions,
                            aiResponse
                    );

            randomQuizAttemptRepository.save(
                    attempt
            );

            return mobileAiRandomQuizMapper.toResponse(
                    attempt
            );

        } catch (AiServiceException ex) {
            throw ex;

        } catch (Exception ex) {
            log.error("AI random quiz generation failed", ex);

            throw new AiServiceException(
                    "AI random quiz generation is currently unavailable",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    ex
            );
        }
    }

    @Transactional
    public RandomQuizSubmitResponse submit(
            Long courseId,
            Long attemptId,
            SubmitRandomQuizRequest request,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        RandomQuizAttempt attempt =
                randomQuizAttemptRepository
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

        return mobileAiRandomQuizMapper.toSubmitResponse(
                attempt
        );
    }


    private RandomQuizAttempt buildAttempt(
            CourseEnrollment enrollment,
            List<Question> selectedQuestions,
            GeneratedRandomQuizResponse aiResponse
    ) {

        Map<Long, Question> sourceQuestionMap =
                selectedQuestions
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        Question::getId,
                                        question -> question
                                )
                        );

        RandomQuizAttempt attempt =
                RandomQuizAttempt.builder()
                        .course(
                                enrollment.getCourse()
                        )
                        .user(
                                enrollment.getUser()
                        )
                        .completed(
                                false
                        )
                        .build();

        for (GeneratedRandomQuizQuestion generated : aiResponse.questions()) {

            Question sourceQuestion =
                    sourceQuestionMap.get(
                            generated.sourceQuestionId()
                    );

            RandomQuizAttemptQuestion attemptQuestion =
                    RandomQuizAttemptQuestion.builder()
                            .attempt(
                                    attempt
                            )
                            .sourceQuestion(
                                    sourceQuestion
                            )
                            .content(
                                    generated.content().trim()
                            )
                            .options(
                                    generated.options()
                            )
                            .correctAnswerIndex(
                                    generated.correctAnswerIndex()
                            )
                            .build();

            attempt.getQuestions()
                    .add(
                            attemptQuestion
                    );
        }

        return attempt;
    }

    private void validateAiResponse(
            GeneratedRandomQuizResponse response,
            List<Question> sourceQuestions
    ) {

        if (
                response == null ||
                        response.questions() == null ||
                        response.questions().size() != RANDOM_QUIZ_SIZE
        ) {
            throw new AiServiceException(
                    "AI must return exactly 10 questions",
                    HttpStatus.SERVICE_UNAVAILABLE,
                    null
            );
        }

        Map<Long, Question> sourceQuestionMap =
                sourceQuestions
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        Question::getId,
                                        question -> question
                                )
                        );

        Set<Long> usedSourceQuestionIds =
                new HashSet<>();

        for (GeneratedRandomQuizQuestion question : response.questions()) {

            if (
                    question.sourceQuestionId() == null ||
                            !sourceQuestionMap.containsKey(
                                    question.sourceQuestionId()
                            )
            ) {
                throw new AiServiceException(
                        "AI returned invalid source question id",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            if (
                    !usedSourceQuestionIds.add(
                            question.sourceQuestionId()
                    )
            ) {
                throw new AiServiceException(
                        "AI returned duplicate source question id",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            if (
                    question.content() == null ||
                            question.content().isBlank()
            ) {
                throw new AiServiceException(
                        "AI returned empty question content",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            Question sourceQuestion =
                    sourceQuestionMap.get(
                            question.sourceQuestionId()
                    );

            if (
                    question.options() == null ||
                            question.options().size() != sourceQuestion.getOptions().size()
            ) {
                throw new AiServiceException(
                        "AI returned invalid options count",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            boolean hasEmptyOption =
                    question.options()
                            .stream()
                            .anyMatch(option ->
                                    option == null || option.isBlank()
                            );

            if (hasEmptyOption) {
                throw new AiServiceException(
                        "AI returned empty option",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }

            if (
                    question.correctAnswerIndex() == null ||
                            question.correctAnswerIndex() < 0 ||
                            question.correctAnswerIndex() >= question.options().size()
            ) {
                throw new AiServiceException(
                        "AI returned invalid correct answer index",
                        HttpStatus.SERVICE_UNAVAILABLE,
                        null
                );
            }
        }
    }
}
