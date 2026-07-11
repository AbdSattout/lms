package app.lms.chapter.service;

import app.lms.chapter.model.Chapter;
import app.lms.chapter.repository.ChapterRepository;

import app.lms.common.exception.NotFoundException;

import app.lms.course.service.CourseAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChapterAccessService {

    private final ChapterRepository chapterRepository;
    private final CourseAccessService courseAccessService;
    public Chapter getById(Long chapterId) {

        return chapterRepository.findById(chapterId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Chapter not found"
                        )
                );
    }



    public Chapter getEditableChapter(Long chapterId, User user) {
        Chapter chapter = getById(chapterId);

        courseAccessService.getEditableCourse(
                chapter.getCourse().getId(),
                user
        );

        return chapter;
    }
    public Chapter getManageableChapter(
            Long chapterId,
            User user
    ) {

        Chapter chapter = getById(chapterId);
        courseAccessService.getManageableCourse(
                chapter.getCourse().getId(),
                user
        );

        return chapter;
    }
}