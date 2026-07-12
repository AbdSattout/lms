package app.lms.chapter.mapper;

import app.lms.chapter.dto.ChapterDetailsResponse;
import app.lms.chapter.dto.ChapterResponse;
import app.lms.chapter.model.Chapter;
import app.lms.lesson.mapper.LessonMapper;
import app.lms.lesson.model.Lesson;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.Comparator;

@Component
@RequiredArgsConstructor
public class ChapterMapper {

    private final LessonMapper lessonMapper;

    public ChapterResponse toResponse(
            Chapter chapter
    ) {

        return new ChapterResponse(
                chapter.getId(),
                chapter.getTitle(),
                chapter.getPosition(),
                chapter.getLessons()
                        .stream()
                        .sorted(
                                Comparator.comparing(
                                        Lesson::getPosition
                                )
                        )
                        .map(
                                lessonMapper::toResponse
                        )
                        .toList()
        );
    }
    public ChapterDetailsResponse toDetailsResponse(
            Chapter chapter
    ) {
        return new ChapterDetailsResponse(
                chapter.getId(),
                chapter.getTitle(),
                chapter.getPosition(),
                chapter.getCourse().getId(),
                chapter.getCourse().getOrganization().getId()
        );
    }
}