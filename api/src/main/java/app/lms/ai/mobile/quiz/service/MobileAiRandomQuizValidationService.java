package app.lms.ai.mobile.quiz.service;

import app.lms.ai.common.exception.AiServiceException;
import app.lms.ai.mobile.quiz.dto.GeneratedRandomQuizQuestion;
import app.lms.ai.mobile.quiz.dto.GeneratedRandomQuizResponse;
import app.lms.question.model.Question;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class MobileAiRandomQuizValidationService {

    public void validateAiResponse(
            GeneratedRandomQuizResponse response,
            List<Question> sourceQuestions,
            int expectedQuestionCount
    ) {

        if (
                response == null ||
                        response.questions() == null ||
                        response.questions().size() != expectedQuestionCount
        ) {
            throw new AiServiceException(
                    "AI must return exactly " + expectedQuestionCount + " questions",
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

            validateSourceQuestion(
                    question,
                    sourceQuestionMap,
                    usedSourceQuestionIds
            );

            validateGeneratedQuestion(
                    question,
                    sourceQuestionMap.get(
                            question.sourceQuestionId()
                    )
            );
        }
    }

    private void validateSourceQuestion(
            GeneratedRandomQuizQuestion question,
            Map<Long, Question> sourceQuestionMap,
            Set<Long> usedSourceQuestionIds
    ) {

        if (
                question.sourceQuestionId() == null ||
                        !sourceQuestionMap.containsKey(
                                question.sourceQuestionId()
                        )
        ) {
            throw unavailable(
                    "AI returned invalid source question id"
            );
        }

        if (
                !usedSourceQuestionIds.add(
                        question.sourceQuestionId()
                )
        ) {
            throw unavailable(
                    "AI returned duplicate source question id"
            );
        }
    }

    private void validateGeneratedQuestion(
            GeneratedRandomQuizQuestion question,
            Question sourceQuestion
    ) {

        if (
                question.content() == null ||
                        question.content().isBlank()
        ) {
            throw unavailable(
                    "AI returned empty question content"
            );
        }

        if (
                question.options() == null ||
                        question.options().size() != sourceQuestion.getOptions().size()
        ) {
            throw unavailable(
                    "AI returned invalid options count"
            );
        }

        boolean hasEmptyOption =
                question.options()
                        .stream()
                        .anyMatch(option ->
                                option == null || option.isBlank()
                        );

        if (hasEmptyOption) {
            throw unavailable(
                    "AI returned empty option"
            );
        }

        if (
                question.correctAnswerIndex() == null ||
                        question.correctAnswerIndex() < 0 ||
                        question.correctAnswerIndex() >= question.options().size()
        ) {
            throw unavailable(
                    "AI returned invalid correct answer index"
            );
        }
    }

    private AiServiceException unavailable(
            String message
    ) {

        return new AiServiceException(
                message,
                HttpStatus.SERVICE_UNAVAILABLE,
                null
        );
    }
}
