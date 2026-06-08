package app.lms.lesson.service;

import app.lms.chapter.service.ChapterAccessService;
import app.lms.common.exception.NotFoundException;
import app.lms.lesson.model.Lesson;
import app.lms.lesson.repository.LessonRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class    LessonAccessService {

    private final LessonRepository lessonRepository;
    private final ChapterAccessService chapterAccessService;

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

        chapterAccessService
                .getEditableChapter(
                        lesson.getChapter().getId(),
                        user
                );

        return lesson;
    }
}
