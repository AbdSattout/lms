package app.lms.practiceQuiz.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.course.model.Course;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.practiceQuiz.dto.CreatePracticeQuizRequest;
import app.lms.practiceQuiz.dto.PracticeQuizPublicResponse;
import app.lms.practiceQuiz.dto.PracticeQuizQuestionResultResponse;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSummaryResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSubmitResponse;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.model.PracticeQuizAttempt;
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
                        .toList(),
                BaseEntityResponse.from(practiceQuiz)
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
                        .map(questionMapper::toPublicResponse)
                        .toList(),
                BaseEntityResponse.from(practiceQuiz)
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
                practiceQuiz.getQuestions().size(),
                BaseEntityResponse.from(practiceQuiz)
        );
    }

    public PracticeQuizSubmitResponse toSubmitResponse(
            PracticeQuizAttempt attempt
    ) {

        return toSubmitResponse(
                attempt,
                List.of()
        );
    }

    public PracticeQuizSubmitResponse toSubmitResponse(
            PracticeQuizAttempt attempt,
            List<GamificationAwardResponse> rewards
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
                        .toList(),
                rewards,
                BaseEntityResponse.from(attempt)
        );
    }


}
