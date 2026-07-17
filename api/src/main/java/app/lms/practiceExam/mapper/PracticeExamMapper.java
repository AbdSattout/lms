package app.lms.practiceExam.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.common.quiz.service.QuizDifficultyService;
import app.lms.course.model.Course;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.practiceExam.dto.*;
import app.lms.practiceExam.model.PracticeExam;
import app.lms.practiceExam.model.PracticeExamAttempt;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class PracticeExamMapper {

    private final QuestionMapper questionMapper;
    private final QuizDifficultyService quizDifficultyService;

    public PracticeExam toEntity(
            CreatePracticeExamRequest request,
            Course course,
            List<Question> questions
    ) {

        return PracticeExam.builder()
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

    public PracticeExamResponse toResponse(
            PracticeExam practiceExam
    ) {

        return new PracticeExamResponse(
                practiceExam.getId(),
                practiceExam.getTitle(),
                practiceExam.getDescription(),
                practiceExam.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceExam.getQuestions()
                ),
                practiceExam.getQuestions()
                        .stream()
                        .map(questionMapper::toResponse)
                        .toList(),
                BaseEntityResponse.from(practiceExam)
        );
    }

    public PracticeExamPublicResponse toPublicResponse(
            PracticeExam practiceExam
    ) {

        return new PracticeExamPublicResponse(
                practiceExam.getId(),
                practiceExam.getTitle(),
                practiceExam.getDescription(),
                practiceExam.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceExam.getQuestions()
                ),
                practiceExam.getQuestions()
                        .stream()
                        .map(questionMapper::toPublicResponse)
                        .toList(),
                BaseEntityResponse.from(practiceExam)
        );
    }

    public PracticeExamSummaryResponse toSummaryResponse(
            PracticeExam practiceExam
    ) {

        return new PracticeExamSummaryResponse(
                practiceExam.getId(),
                practiceExam.getTitle(),
                practiceExam.getDescription(),
                practiceExam.getCourse().getId(),
                quizDifficultyService.calculate(
                        practiceExam.getQuestions()
                ),
                practiceExam.getQuestions().size(),
                BaseEntityResponse.from(practiceExam)
        );
    }

    public PracticeExamSubmitResponse toSubmitResponse(
            PracticeExamAttempt attempt,
            List<GamificationAwardResponse> rewards
    ) {

        return new PracticeExamSubmitResponse(
                attempt.getId(),
                attempt.getScore(),
                attempt.getTotal(),
                attempt.getAnswers()
                        .stream()
                        .map(answer ->
                                new PracticeExamQuestionResultResponse(
                                        answer.getSourceQuestion().getId(),
                                        answer.getContent(),
                                        answer.getOptions(),
                                        answer.getSelectedAnswerIndex(),
                                        answer.getCorrectAnswerIndex(),
                                        answer.getCorrect(),
                                        BaseEntityResponse.from(answer)
                                )
                        )
                        .toList(),
                rewards,
                BaseEntityResponse.from(attempt)
        );
    }
}
