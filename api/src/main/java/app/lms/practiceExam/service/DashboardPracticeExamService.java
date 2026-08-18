package app.lms.practiceExam.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.quiz.service.QuizQuestionSelectionService;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceExam.dto.CreatePracticeExamRequest;
import app.lms.practiceExam.dto.PracticeExamResponse;
import app.lms.practiceExam.dto.UpdatePracticeExamQuestionsRequest;
import app.lms.practiceExam.enums.PracticeExamStatus;
import app.lms.practiceExam.mapper.PracticeExamMapper;
import app.lms.practiceExam.model.PracticeExam;
import app.lms.practiceExam.repository.PracticeExamAttemptRepository;
import app.lms.practiceExam.repository.PracticeExamRepository;
import app.lms.question.model.Question;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DashboardPracticeExamService {

    private final CourseAccessService courseAccessService;
    private final PracticeExamRepository practiceExamRepository;
    private final PracticeExamAttemptRepository practiceExamAttemptRepository;
    private final PracticeExamMapper practiceExamMapper;
    private final QuizQuestionSelectionService quizQuestionSelectionService;
    private final PracticeExamAccessService practiceExamAccessService;

    @Transactional
    public PracticeExamResponse create(
            Long courseId,
            CreatePracticeExamRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        List<Question> questions =
                quizQuestionSelectionService
                        .getManageableCourseQuestions(
                                request.questionIds(),
                                course.getId(),
                                user,
                                "practice exam"
                        );

        PracticeExam practiceExam =
                practiceExamMapper.toEntity(
                        request,
                        course,
                        questions
                );

        practiceExamRepository.save(
                practiceExam
        );

        return practiceExamMapper.toResponse(
                practiceExam
        );
    }

    @Transactional
    public PracticeExamResponse updateQuestions(
            Long courseId,
            Long practiceExamId,
            UpdatePracticeExamQuestionsRequest request,
            User user
    ) {

        PracticeExam practiceExam =
                practiceExamAccessService
                        .getEditablePracticeExam(
                                courseId,
                                practiceExamId,
                                user
                        );

        List<Question> updatedQuestions =
                quizQuestionSelectionService
                        .getManageableCourseQuestions(
                                request.questionIds(),
                                practiceExam.getCourse().getId(),
                                user,
                                "practice exam"
                        );

        practiceExam.getQuestions()
                .clear();

        practiceExam.getQuestions()
                .addAll(
                        updatedQuestions
                );

        return practiceExamMapper.toResponse(
                practiceExam
        );
    }

    @Transactional
    public List<PracticeExamResponse> list(
            Long courseId,
            User user
    ) {

        return practiceExamAccessService
                .getManageablePracticeExams(
                        courseId,
                        user
                )
                .stream()
                .map(practiceExamMapper::toResponse)
                .toList();
    }

    @Transactional
    public PracticeExamResponse getById(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        PracticeExam practiceExam =
                practiceExamAccessService
                        .getManageablePracticeExam(
                                courseId,
                                practiceExamId,
                                user
                        );

        return practiceExamMapper.toResponse(
                practiceExam
        );
    }

    @Transactional
    public void delete(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        PracticeExam practiceExam =
                practiceExamAccessService
                        .getEditablePracticeExam(
                                courseId,
                                practiceExamId,
                                user
                        );

        practiceExamAttemptRepository.deleteAll(
                practiceExamAttemptRepository
                        .findAllByPracticeExamId(
                                practiceExam.getId()
                        )
        );

        practiceExamRepository.delete(
                practiceExam
        );
    }

    @Transactional
    public PracticeExamResponse publish(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        PracticeExam practiceExam =
                practiceExamAccessService
                        .getManageablePracticeExam(
                                courseId,
                                practiceExamId,
                                user
                        );

        validateNotPublished(
                practiceExam
        );

        practiceExam.setStatus(
                PracticeExamStatus.PUBLISHED
        );

        return practiceExamMapper.toResponse(
                practiceExam
        );
    }

    private void validateNotPublished(
            PracticeExam practiceExam
    ) {

        if (practiceExam.getStatus()
                == PracticeExamStatus.PUBLISHED) {
            throw new ConflictException(
                    "Practice exam already published"
            );
        }
    }
}
