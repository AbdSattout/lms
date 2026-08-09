package app.lms.randomquiz.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.randomquiz.dto.BankRandomQuizQuestionResultResponse;
import app.lms.randomquiz.dto.BankRandomQuizResponse;
import app.lms.randomquiz.dto.BankRandomQuizSubmitResponse;
import app.lms.randomquiz.model.BankRandomQuizAttempt;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class BankRandomQuizMapper {

    private final QuizDifficultyService quizDifficultyService;

    public BankRandomQuizResponse toResponse(
            BankRandomQuizAttempt attempt
    ) {

        return new BankRandomQuizResponse(
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
                                        question.getSourceQuestion().getDifficulty(),
                                        BaseEntityResponse.from(question)
                                )
                        )
                        .toList(),
                BaseEntityResponse.from(attempt)
        );
    }

    public BankRandomQuizSubmitResponse toSubmitResponse(
            BankRandomQuizAttempt attempt
    ) {

        return new BankRandomQuizSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getQuestions().size(),
                attempt.getQuestions()
                        .stream()
                        .map(question ->
                                new BankRandomQuizQuestionResultResponse(
                                        question.getId(),
                                        question.getContent(),
                                        question.getOptions(),
                                        question.getSelectedAnswerIndex(),
                                        question.getCorrectAnswerIndex(),
                                        question.getCorrect(),
                                        BaseEntityResponse.from(question)
                                )
                        )
                        .toList(),
                BaseEntityResponse.from(attempt)
        );
    }
}
