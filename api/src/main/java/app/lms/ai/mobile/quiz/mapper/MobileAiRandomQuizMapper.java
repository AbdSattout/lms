package app.lms.ai.mobile.quiz.mapper;

import app.lms.ai.mobile.quiz.dto.RandomQuizQuestionResultResponse;
import app.lms.ai.mobile.quiz.dto.RandomQuizSubmitResponse;
import app.lms.ai.mobile.quiz.model.RandomQuizAttempt;
import org.springframework.stereotype.Component;

@Component
public class MobileAiRandomQuizMapper {
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
