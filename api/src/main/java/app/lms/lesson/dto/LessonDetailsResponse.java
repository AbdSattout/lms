package app.lms.lesson.dto;

public record LessonDetailsResponse(
        Long id,
        String title,
        Integer position,
        Long chapterId,
        Long courseId,
        Long organizationId
) {
}