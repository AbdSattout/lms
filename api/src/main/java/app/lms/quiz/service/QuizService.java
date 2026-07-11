package app.lms.quiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import app.lms.question.service.QuestionAccessService;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.mapper.QuizMapper;
import app.lms.quiz.model.Quiz;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class QuizService {

    private final QuizMapper quizMapper;
    private final QuestionMapper questionMapper;
    private final QuestionAccessService questionAccessService;
    private final QuizAccessService quizAccessService;
    @Transactional
    public QuizResponse getQuizById(
            Long quizId,
            User user
    ) {

        Quiz quiz =
                quizAccessService.getManageableQuiz(
                        quizId,
                        user
                );

        return quizMapper.toResponse(
                quiz
        );
    }

    @Transactional
    public QuestionResponse addQuestionToQuiz(
            Long quizId,
            Long questionId,
            User user
    ) {

        Quiz quiz =
                quizAccessService.getManageableQuiz(
                        quizId,
                        user
                );

        Question question =
                questionAccessService
                        .getManageableQuestion(
                                questionId,
                                user
                        );

        validateQuestionBelongsToQuizCourse(
                quiz,
                question
        );

        boolean alreadyExists =
                quiz.getQuestions()
                        .stream()
                        .anyMatch(q ->
                                q.getId().equals(
                                        question.getId()
                                )
                        );

        if (alreadyExists) {
            throw new ConflictException(
                    "Question already exists in this quiz"
            );
        }

        quiz.getQuestions()
                .add(
                        question
                );

        return questionMapper.toResponse(
                question
        );
    }

    @Transactional
    public void deleteQuestionFromQuiz(
            Long quizId,
            Long questionId,
            User user
    ) {

        Quiz quiz =
                quizAccessService.getManageableQuiz(
                        quizId,
                        user
                );

        boolean removed =
                quiz.getQuestions()
                        .removeIf(question ->
                                question.getId().equals(
                                        questionId
                                )
                        );

        if (!removed) {
            throw new NotFoundException(
                    "Question not found in this quiz"
            );
        }
    }



    private void validateQuestionBelongsToQuizCourse(
            Quiz quiz,
            Question question
    ) {

        Long quizCourseId =
                quiz.getCourse()
                        .getId();

        Long questionCourseId =
                question.getCourse()
                        .getId();

        if (!quizCourseId.equals(questionCourseId)) {
            throw new BadRequestException(
                    "Question must belong to the same course as the quiz"
            );
        }
    }
}