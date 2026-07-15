package app.lms.practiceExam.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.practiceExam.model.PracticeExam;
import app.lms.practiceExam.repository.PracticeExamRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PracticeExamAccessService {

    private final PracticeExamRepository practiceExamRepository;
    private final CourseAccessService courseAccessService;

    public PracticeExam getEditablePracticeExam(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        return practiceExamRepository
                .findByIdAndCourseId(
                        practiceExamId,
                        course.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Practice exam not found"
                        )
                );
    }

    public PracticeExam getManageablePracticeExam(
            Long courseId,
            Long practiceExamId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return practiceExamRepository
                .findByIdAndCourseId(
                        practiceExamId,
                        course.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Practice exam not found"
                        )
                );
    }

    public List<PracticeExam> getManageablePracticeExams(
            Long courseId,
            User user
    ) {

        Course course =
                courseAccessService
                        .getManageableCourse(
                                courseId,
                                user
                        );

        return practiceExamRepository
                .findAllByCourseIdOrderByCreatedAtDesc(
                        course.getId()
                );
    }
}
