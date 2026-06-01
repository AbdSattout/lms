package app.lms.chapter.mapper;

import app.lms.chapter.dto.ChapterResponse;
import app.lms.chapter.model.Chapter;
import org.springframework.stereotype.Component;

@Component
public class ChapterMapper {

    public ChapterResponse toResponse(
            Chapter chapter
    ) {

        return new ChapterResponse(
                chapter.getId(),
                chapter.getTitle(),
                chapter.getPosition()
        );
    }
}