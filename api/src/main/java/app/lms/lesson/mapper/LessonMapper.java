package app.lms.lesson.mapper;

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
                lesson.getIsPublished()
        );
    }
}
