package app.lms.quiz.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.mapper.QuestionMapper;
import app.lms.quiz.dto.FinalQuizQuestionResultResponse;
import app.lms.quiz.dto.FinalQuizResponse;
import app.lms.quiz.dto.FinalQuizSubmitResponse;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.model.FinalQuizAttempt;
import app.lms.quiz.model.Quiz;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class QuizMapper {

    private final QuestionMapper questionMapper;
    private final QuizDifficultyService quizDifficultyService;

    public QuizResponse toResponse(Quiz quiz) {
        return new QuizResponse(
                quiz.getId(),
                quiz.getTitle(),
                quiz.getCourse().getId(),
                quizDifficultyService.calculate(
                        quiz.getQuestions()
                ),
                quiz.getQuestions().stream()
                        .map(questionMapper::toResponse)
                        .collect(Collectors.toList()),
                BaseEntityResponse.from(quiz)
        );
    }

    public FinalQuizResponse toPublicResponse(
            Quiz quiz
    ) {

        return new FinalQuizResponse(
                quiz.getId(),
                quiz.getCourse().getId(),
                quizDifficultyService.calculate(
                        quiz.getQuestions()
                ),
                quiz.getQuestions()
                        .stream()
                        .map(questionMapper::toPublicResponse)
                        .toList(),
                BaseEntityResponse.from(quiz)
        );
    }

    public FinalQuizSubmitResponse toSubmitResponse(
            FinalQuizAttempt attempt
    ) {

        return toSubmitResponse(
                attempt,
                List.of()
        );
    }

    public FinalQuizSubmitResponse toSubmitResponse(
            FinalQuizAttempt attempt,
            List<GamificationAwardResponse> rewards
    ) {

        return new FinalQuizSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getTotal(),
                attempt.getAnswers()
                        .stream()
                        .map(answer ->
                                new FinalQuizQuestionResultResponse(
                                        answer.getSourceQuestion()
                                                .getId(),
                                        answer.getContent(),
                                        answer.getOptions(),
                                        answer.getSelectedAnswerIndex(),
                                        answer.getCorrectAnswerIndex(),
                                        answer.getCorrect()
                                )
                        )
                        .toList(),
                rewards,
                BaseEntityResponse.from(attempt)
        );
    }
}
