package app.lms.practiceQuiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.service.QuizQuestionSelectionService;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceQuiz.dto.CreatePracticeQuizRequest;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.UpdatePracticeQuizQuestionsRequest;
import app.lms.practiceQuiz.mapper.PracticeQuizMapper;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.question.model.Question;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardPracticeQuizService {

    private final CourseAccessService courseAccessService;
    private final PracticeQuizRepository practiceQuizRepository;
    private final PracticeQuizMapper practiceQuizMapper;
    private final QuizQuestionSelectionService quizQuestionSelectionService;

    @Transactional
    public PracticeQuizResponse create(
            Long courseId,
            CreatePracticeQuizRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        List<Question> questions =
                quizQuestionSelectionService
                        .getManageableCourseQuestions(
                                request.questionIds(),
                                course.getId(),
                                user,
                                "practice quiz"
                        );

        PracticeQuiz practiceQuiz =
                PracticeQuiz.builder()
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

        practiceQuizRepository.save(
                practiceQuiz
        );

        return practiceQuizMapper.toResponse(
                practiceQuiz
        );
    }

    @Transactional
    public PracticeQuizResponse updateQuestions(
            Long courseId,
            Long practiceQuizId,
            UpdatePracticeQuizQuestionsRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findByIdAndCourseId(
                                practiceQuizId,
                                course.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice quiz not found"
                                )
                        );

        List<Question> updatedQuestions =
                quizQuestionSelectionService
                        .getManageableCourseQuestions(
                                request.questionIds(),
                                course.getId(),
                                user,
                                "practice quiz"
                        );

        practiceQuiz.getQuestions()
                .clear();

        practiceQuiz.getQuestions()
                .addAll(
                        updatedQuestions
                );

        return practiceQuizMapper.toResponse(
                practiceQuiz
        );
    }
    @Transactional
    public List<PracticeQuizResponse> list(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return practiceQuizRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        course.getId()
                )
                .stream()
                .map(practiceQuizMapper::toResponse)
                .toList();
    }

}
