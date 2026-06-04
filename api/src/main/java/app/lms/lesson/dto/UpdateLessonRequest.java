package app.lms.lesson.dto;

public record UpdateLessonRequest(

        String title,

        Boolean isPublished

) {
}
