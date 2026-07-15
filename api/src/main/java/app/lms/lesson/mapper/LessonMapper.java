package app.lms.lesson.mapper;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.lesson.dto.LessonDetailsResponse;
import app.lms.lesson.dto.LessonResponse;
import app.lms.lesson.model.Lesson;
import org.springframework.stereotype.Component;

@Component
public class LessonMapper {

    public LessonResponse toResponse(
            Lesson lesson
    ) {
        return new LessonResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getPosition(),
                BaseEntityResponse.from(lesson)

        );
    }
    public LessonDetailsResponse toDetailsResponse(
            Lesson lesson
    ) {
        return new LessonDetailsResponse(
                lesson.getId(),
                lesson.getTitle(),
                lesson.getPosition(),
                lesson.getChapter().getId(),
                lesson.getChapter().getCourse().getId(),
                lesson.getChapter().getCourse().getOrganization().getId(),
                BaseEntityResponse.from(lesson)
        );
    }
}
