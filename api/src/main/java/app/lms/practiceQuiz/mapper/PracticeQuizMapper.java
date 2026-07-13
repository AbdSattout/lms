package app.lms.practiceQuiz.mapper;

import app.lms.practiceQuiz.dto.PracticeQuizPublicResponse;
import app.lms.practiceQuiz.dto.PracticeQuizQuestionResultResponse;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.PracticeQuizSubmitResponse;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.model.PracticeQuizAttempt;
import app.lms.question.dto.QuestionPublicResponse;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.mapper.QuestionMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PracticeQuizMapper {

    private final QuestionMapper questionMapper;

    public PracticeQuizResponse toResponse(
            PracticeQuiz practiceQuiz
    ) {

        return new PracticeQuizResponse(
                practiceQuiz.getId(),
                practiceQuiz.getTitle(),
                practiceQuiz.getDescription(),
                practiceQuiz.getCourse().getId(),
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
