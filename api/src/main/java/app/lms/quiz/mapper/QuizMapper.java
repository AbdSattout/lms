package app.lms.quiz.mapper;

import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.question.mapper.QuestionMapper;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.model.Quiz;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

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
                        .collect(Collectors.toList())
        );
    }
}
