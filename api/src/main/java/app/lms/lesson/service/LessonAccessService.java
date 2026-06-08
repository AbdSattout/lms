package app.lms.lesson.service;

import app.lms.common.exception.NotFoundException;
import app.lms.course.service.CourseAccessService;
import app.lms.lesson.model.Lesson;
import app.lms.lesson.repository.LessonRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class    LessonAccessService {

    private final LessonRepository lessonRepository;
    private final CourseAccessService courseAccessService;
    public Lesson getEditableLesson(
            Long lessonId,
            User user
    ) {

        Lesson lesson =
                lessonRepository.findById(
                                lessonId
                        )
                        .orElseThrow(
                                () -> new NotFoundException(
                                        "Lesson not found"
                                )
                        );

        Long courseId = lesson.getChapter()
                        .getCourse()
                        .getId();

        courseAccessService
                .getEditableCourse(
                       courseId,
                        user
                );

        return lesson;
    }
}
