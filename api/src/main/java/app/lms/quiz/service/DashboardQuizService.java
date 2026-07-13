package app.lms.quiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.question.model.Question;
import app.lms.question.service.QuestionAccessService;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.dto.UpdateFinalQuizQuestionsRequest;
import app.lms.quiz.mapper.QuizMapper;
import app.lms.quiz.model.Quiz;
import app.lms.quiz.repository.QuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardQuizService {

    private final QuizMapper quizMapper;
    private final CourseAccessService courseAccessService;
    private final QuestionAccessService questionAccessService;
    private final QuizRepository quizRepository;

    @Transactional
    public QuizResponse getFinalQuizByCourseId(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        Quiz quiz =
                quizRepository
                        .findByCourseId(
                                course.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Final quiz not found"
                                )
                        );

        return quizMapper.toResponse(
                quiz
        );
    }

    @Transactional
    public QuizResponse updateFinalQuizQuestions(
            Long courseId,
            UpdateFinalQuizQuestionsRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        Quiz quiz =
                quizRepository
                        .findByCourseId(
                                course.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Final quiz not found"
                                )
                        );

        if (
                request.questionIds()
                        .stream()
                        .distinct()
                        .count()
                        != request.questionIds().size()
        ) {
            throw new ConflictException(
                    "Duplicate questions are not allowed"
            );
        }

        List<Question> updatedQuestions =
                request.questionIds()
                        .stream()
                        .map(questionId ->
                                questionAccessService
                                        .getManageableQuestion(
                                                questionId,
                                                user
                                        )
                        )
                        .toList();

        for (Question question : updatedQuestions) {
            validateQuestionBelongsToCourse(
                    question,
                    course.getId()
            );
        }

        quiz.getQuestions()
                .clear();

        quiz.getQuestions()
                .addAll(
                        updatedQuestions
                );

        return quizMapper.toResponse(
                quiz
        );
    }

    private void validateQuestionBelongsToCourse(
            Question question,
            Long courseId
    ) {

        Long questionCourseId =
                question.getCourse()
                        .getId();

        if (!questionCourseId.equals(courseId)) {
            throw new BadRequestException(
                    "Question must belong to the same course as the final quiz"
            );
        }
    }
}