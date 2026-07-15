package app.lms.ai.mobile.quiz.mapper;

import app.lms.ai.mobile.quiz.dto.RandomQuizResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizQuestionResultResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizSubmitResponse;
import app.lms.ai.mobile.quiz.dto.GeneratedRandomQuizResponse;
import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import app.lms.ai.mobile.quiz.model.RandomQuizAttemptQuestion;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.model.Question;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class MobileAiRandomQuizMapper {

    private final QuizDifficultyService quizDifficultyService;

    public RandomQuizAttempt toAttempt(
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

        aiResponse.questions()
                .forEach(generated -> {

                    RandomQuizAttemptQuestion attemptQuestion =
                            RandomQuizAttemptQuestion.builder()
                                    .attempt(
                                            attempt
                                    )
                                    .sourceQuestion(
                                            sourceQuestionMap.get(
                                                    generated.sourceQuestionId()
                                            )
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
                });

        return attempt;
    }

    public RandomQuizResponse toResponse(
            RandomQuizAttempt attempt
    ) {

        return new RandomQuizResponse(
                attempt.getId(),
                quizDifficultyService.calculate(
                        attempt.getQuestions(),
                        question -> question.getSourceQuestion()
                                .getDifficulty()
                ),
                attempt.getQuestions()
                        .stream()
                        .map(question ->
                                new QuestionPublicResponse(
                                        question.getId(),
                                        question.getContent(),
                                        question.getOptions(),
                                        BaseEntityResponse.from(question)
                                )
                        )
                        .toList(),
                BaseEntityResponse.from(attempt)
        );
    }

    public RandomQuizSubmitResponse toSubmitResponse(
            RandomQuizAttempt attempt
    ) {

        return new RandomQuizSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getQuestions().size(),
                attempt.getQuestions()
                        .stream()
                        .map(question ->
                                new RandomQuizQuestionResultResponse(
                                        question.getId(),
                                        question.getContent(),
                                        question.getOptions(),
                                        question.getSelectedAnswerIndex(),
                                        question.getCorrectAnswerIndex(),
                                        question.getCorrect()
                                )
                        )
                        .toList(),
                BaseEntityResponse.from(attempt)
        );
    }
}
