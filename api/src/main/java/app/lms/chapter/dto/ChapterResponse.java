package app.lms.chapter.dto;

import app.lms.lesson.dto.LessonResponse;

import java.util.List;

public record ChapterResponse(

        Long id,
        String title,
        Integer position,
         List<LessonResponse>lessons

) {
}