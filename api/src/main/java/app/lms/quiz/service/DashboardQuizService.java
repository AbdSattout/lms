package app.lms.quiz.service;

import app.lms.common.quiz.service.QuizQuestionSelectionService;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.question.model.Question;
import app.lms.quiz.dto.QuizResponse;
import app.lms.quiz.dto.UpdateFinalQuizQuestionsRequest;
import app.lms.quiz.mapper.QuizMapper;
import app.lms.quiz.model.Quiz;
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
    private final QuizAccessService quizAccessService;
    private final QuizQuestionSelectionService quizQuestionSelectionService;

    @Transactional
    public QuizResponse getFinalQuizByCourseId(
            Long courseId,
            User user
    ) {

        Quiz quiz =
                quizAccessService
                        .getManageableQuizByCourseId(
                                courseId,
                                user
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
                quizAccessService
                        .getEditableQuizByCourseId(
                                course.getId(),
                                user
                        );

        List<Question> updatedQuestions =
                quizQuestionSelectionService
                        .getManageableCourseQuestions(
                                request.questionIds(),
                                course.getId(),
                                user,
                                "final quiz"
                        );

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

}
