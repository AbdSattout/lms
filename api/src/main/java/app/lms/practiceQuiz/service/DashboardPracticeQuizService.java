package app.lms.practiceQuiz.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceQuiz.dto.CreatePracticeQuizRequest;
import app.lms.practiceQuiz.dto.PracticeQuizResponse;
import app.lms.practiceQuiz.dto.UpdatePracticeQuizQuestionsRequest;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.question.dto.QuestionResponse;
import app.lms.question.mapper.QuestionMapper;
import app.lms.question.model.Question;
import app.lms.question.service.QuestionAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardPracticeQuizService {

    private final CourseAccessService courseAccessService;
    private final QuestionAccessService questionAccessService;
    private final PracticeQuizRepository practiceQuizRepository;
    private final QuestionMapper questionMapper;

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

        List<Long> questionIds =
                request.questionIds()
                        .stream()
                        .distinct()
                        .toList();

        if (questionIds.size() != request.questionIds().size()) {
            throw new ConflictException(
                    "Duplicate questions are not allowed"
            );
        }

        List<Question> questions =
                questionIds
                        .stream()
                        .map(questionId ->
                                questionAccessService
                                        .getManageableQuestion(
                                                questionId,
                                                user
                                        )
                        )
                        .toList();

        for (Question question : questions) {
            validateQuestionBelongsToCourse(
                    question,
                    course.getId()
            );
        }

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

        return toResponse(
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

        practiceQuiz.getQuestions()
                .clear();

        practiceQuiz.getQuestions()
                .addAll(
                        updatedQuestions
                );

        return toResponse(
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
                .map(this::toResponse)
                .toList();
    }

    private PracticeQuizResponse toResponse(
            PracticeQuiz practiceQuiz
    ) {

        List<QuestionResponse> questions =
                practiceQuiz.getQuestions()
                        .stream()
                        .map(questionMapper::toResponse)
                        .toList();

        return new PracticeQuizResponse(
                practiceQuiz.getId(),
                practiceQuiz.getTitle(),
                practiceQuiz.getDescription(),
                practiceQuiz.getCourse().getId(),
                questions
        );
    }

    private void validateQuestionBelongsToCourse(
            Question question,
            Long courseId
    ) {

        if (!question.getCourse().getId().equals(courseId)) {
            throw new BadRequestException(
                    "Question must belong to the same course as the practice quiz"
            );
        }
    }
}