package app.lms.practiceQuiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.common.quiz.dto.QuizGradingResult;
import app.lms.common.quiz.service.QuizGradingService;
import app.lms.courceEnrollment.service.CourseEnrollmentAccessService;
import app.lms.practiceQuiz.dto.*;
import app.lms.practiceQuiz.mapper.PracticeQuizMapper;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;


@Service
@RequiredArgsConstructor
public class MobilePracticeQuizService {

    private final PracticeQuizRepository practiceQuizRepository;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;
    private final PracticeQuizMapper practiceQuizMapper;
    private final QuizGradingService  quizGradingService;

    @Transactional
    public PracticeQuizPublicResponse getPracticeQuiz(
            Long courseId,
            Long practiceQuizId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findByIdAndCourseId(
                                practiceQuizId,
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice quiz not found"
                                )
                        );

        return practiceQuizMapper.toPublicResponse(
                practiceQuiz
        );
    }

    @Transactional
    public List<PracticeQuizSummaryResponse> list(
            Long courseId,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        return practiceQuizRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        courseId
                )
                .stream()
                .map(practiceQuizMapper::toSummaryResponse)
                .toList();
    }
    @Transactional
    public PracticeQuizSubmitResponse submit(
            Long courseId,
            Long practiceQuizId,
            SubmitPracticeQuizRequest request,
            User user
    ) {

        courseEnrollmentAccessService.getEnrollment(
                courseId,
                user
        );

        PracticeQuiz practiceQuiz =
                practiceQuizRepository
                        .findByIdAndCourseId(
                                practiceQuizId,
                                courseId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Practice quiz not found"
                                )
                        );

        List<PracticeQuizGradingQuestion> questions =
                practiceQuiz.getQuestions()
                        .stream()
                        .map(question ->
                                new PracticeQuizGradingQuestion(
                                        question.getId(),
                                        question.getContent(),
                                        question.getOptions(),
                                        question.getCorrectAnswerIndex()
                                )
                        )
                        .toList();

        QuizGradingResult gradingResult =
                quizGradingService.grade(
                        questions,
                        request.answers()
                );

        return practiceQuizMapper.toSubmitResponse(
                gradingResult.score(),
                gradingResult.total(),
                questions
        );
    }

}
