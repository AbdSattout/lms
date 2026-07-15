package app.lms.ai.mobile.quiz.service;

import app.lms.ai.common.exception.AiServiceException;
import app.lms.ai.mobile.quiz.dto.*;
import app.lms.ai.mobile.quiz.mapper.MobileAiRandomQuizMapper;
import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import app.lms.ai.mobile.quiz.repository.RandomQuizAttemptRepository;
import app.lms.common.exception.BadRequestException;
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
    private final MobileAiRandomQuizAccessService mobileAiRandomQuizAccessService;
    private final MobileAiRandomQuizValidationService mobileAiRandomQuizValidationService;
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

            mobileAiRandomQuizValidationService.validateAiResponse(
                    aiResponse,
                    selectedQuestions,
                    RANDOM_QUIZ_SIZE
            );

            RandomQuizAttempt attempt =
                    mobileAiRandomQuizMapper.toAttempt(
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
                mobileAiRandomQuizAccessService
                        .getAttempt(
                                courseId,
                                attemptId,
                                user
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


}
