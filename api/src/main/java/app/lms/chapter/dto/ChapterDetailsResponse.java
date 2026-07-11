package app.lms.chapter.dto;

public record ChapterDetailsResponse(
        Long id,
        String title,
        Integer position,
        Long courseId,
        Long organizationId
) {
}