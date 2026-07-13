package app.lms.practiceQuiz.mapper;

import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.course.model.Course;
import app.lms.practiceQuiz.dto.CreatePracticeQuizRequest;
import app.lms.practiceQuiz.dto.PracticeQuizPublicResponse;
import app.lms.practiceQuiz.dto.PracticeQuizQuestionResultResponse;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSummaryResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSubmitResponse;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.model.PracticeQuizAttempt;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class PracticeQuizMapper {

    private final QuestionMapper questionMapper;
    private final QuizDifficultyService quizDifficultyService;

    public PracticeQuiz toEntity(
            CreatePracticeQuizRequest request,
            Course course,
            List<Question> questions
    ) {

        return PracticeQuiz.builder()
                .title(
                        request.title().trim()
                )
                .description(
                        request.description() != null
                                ? request.description().trim()
                                : null
                )
                .course(course)
                .questions(questions)
                .build();
    }

    public PracticeQuizResponse toResponse(
            PracticeQuiz practiceQuiz
    ) {

        return new PracticeQuizResponse(
                practiceQuiz.getId(),
                practiceQuiz.getTitle(),
                practiceQuiz.getDescription(),
                practiceQuiz.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceQuiz.getQuestions()
                ),
                practiceQuiz.getQuestions()
                        .stream()
                        .map(questionMapper::toResponse)
                        .toList()
        );
    }

    public PracticeQuizPublicResponse toPublicResponse(
            PracticeQuiz practiceQuiz
    ) {

        return new PracticeQuizPublicResponse(
                practiceQuiz.getId(),
                practiceQuiz.getTitle(),
                practiceQuiz.getDescription(),
                practiceQuiz.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceQuiz.getQuestions()
                ),
                practiceQuiz.getQuestions()
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

    public PracticeQuizSummaryResponse toSummaryResponse(
            PracticeQuiz practiceQuiz
    ) {

        return new PracticeQuizSummaryResponse(
                practiceQuiz.getId(),
                practiceQuiz.getTitle(),
                practiceQuiz.getDescription(),
                practiceQuiz.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceQuiz.getQuestions()
                ),
                practiceQuiz.getQuestions().size()
        );
    }

    public PracticeQuizSubmitResponse toSubmitResponse(
            PracticeQuizAttempt attempt
    ) {

        return new PracticeQuizSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getTotal(),
                attempt.getAnswers()
                        .stream()
                        .map(answer ->
                                new PracticeQuizQuestionResultResponse(
                                        answer.getSourceQuestion().getId(),
                                        answer.getContent(),
                                        answer.getOptions(),
                                        answer.getSelectedAnswerIndex(),
                                        answer.getCorrectAnswerIndex(),
                                        answer.getCorrect()
                                )
                        )
                        .toList()
        );
    }


}
