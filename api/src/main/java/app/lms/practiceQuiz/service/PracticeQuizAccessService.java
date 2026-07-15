package app.lms.practiceQuiz.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceQuiz.model.PracticeQuiz;
import app.lms.practiceQuiz.repository.PracticeQuizRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PracticeQuizAccessService {

    private final PracticeQuizRepository practiceQuizRepository;
    private final CourseAccessService courseAccessService;

    public PracticeQuiz getEditablePracticeQuiz(
            Long courseId,
            Long practiceQuizId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        return practiceQuizRepository
                .findByIdAndCourseId(
                        practiceQuizId,
                        course.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Practice quiz not found"
                        )
                );
    }

    public List<PracticeQuiz> getManageablePracticeQuizzes(
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
                );
    }

    public PracticeQuiz getManageablePracticeQuiz(
            Long courseId,
            Long practiceQuizId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return practiceQuizRepository
                .findByIdAndCourseId(
                        practiceQuizId,
                        course.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Practice quiz not found"
                        )
                );
    }
}
