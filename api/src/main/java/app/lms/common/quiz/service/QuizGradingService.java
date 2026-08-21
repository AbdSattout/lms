package app.lms.common.quiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.interfaces.GradableQuizQuestion;
import app.lms.common.quiz.interfaces.SubmittedQuizAnswer;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class QuizGradingService {

    public <Q extends GradableQuizQuestion, A extends SubmittedQuizAnswer>
    QuizGradingResult grade(
            List<Q> questions,
            List<A> submittedAnswers
    ) {

        if (submittedAnswers.size() != questions.size()) {
            throw new BadRequestException(
                    "You must answer all quiz questions"
            );
        }

        Map<Long, Integer> answers =
                submittedAnswers
                        .stream()
                        .collect(
                                Collectors.toMap(
                                        SubmittedQuizAnswer::questionId,
                                        SubmittedQuizAnswer::answerIndex,
                                        (_, _) -> {
                                            throw new BadRequestException(
                                                    "Duplicate question answer"
                                            );
                                        }
                                )
                        );

        int score = 0;

        for (Q question : questions) {

            Long questionId =
                    question.gradingQuestionId();

            Integer selectedAnswerIndex =
                    answers.get(
                            questionId
                    );

            if (selectedAnswerIndex == null) {
                throw new BadRequestException(
                        "Missing answer for question: " + questionId
                );
            }

            if (
                    selectedAnswerIndex < -1
                            ||
                            selectedAnswerIndex >= question.getOptions().size()
            ) {
                throw new BadRequestException(
                        "Invalid answer index for question: " + questionId
                );
            }

            boolean correct =
                    selectedAnswerIndex != -1
                            &&
                            question.getCorrectAnswerIndex()
                                    .equals(
                                            selectedAnswerIndex
                                    );

            question.setSelectedAnswerIndex(
                    selectedAnswerIndex
            );

            question.setCorrect(
                    correct
            );

            if (correct) {
                score++;
            }
        }

        return new QuizGradingResult(
                score,
                questions.size()
        );
    }
}