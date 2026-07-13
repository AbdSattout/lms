package app.lms.common.quiz.service;

import app.lms.question.enums.QuestionDifficulty;
import app.lms.question.model.Question;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.function.Function;

@Service
public class QuizDifficultyService {

    public QuestionDifficulty calculate(
            Collection<Question> questions
    ) {

        return calculate(
                questions,
                Question::getDifficulty
        );
    }

    public <T> QuestionDifficulty calculate(
            Collection<T> questions,
            Function<T, QuestionDifficulty> difficultyResolver
    ) {

        if (questions == null || questions.isEmpty()) {
            return QuestionDifficulty.MEDIUM;
        }

        double average =
                questions.stream()
                        .map(difficultyResolver)
                        .mapToInt(this::score)
                        .average()
                        .orElse(2);

        if (average < 1.5) {
            return QuestionDifficulty.EASY;
        }

        if (average >= 2.5) {
            return QuestionDifficulty.HARD;
        }

        return QuestionDifficulty.MEDIUM;
    }

    private int score(
            QuestionDifficulty difficulty
    ) {

        if (difficulty == null) {
            return 2;
        }

        return switch (difficulty) {
            case EASY -> 1;
            case MEDIUM -> 2;
            case HARD -> 3;
        };
    }
}
