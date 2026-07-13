package app.lms.ai.mobile.quiz.mapper;

import app.lms.ai.mobile.quiz.dto.RandomQuizResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizQuestionResultResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizSubmitResponse;
import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.question.dto.QuestionPublicResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class MobileAiRandomQuizMapper {

    private final QuizDifficultyService quizDifficultyService;

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
                                        question.getOptions()
                                )
                        )
                        .toList()
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
                        .toList()
        );
    }
}
