package app.lms.faq.dto;

public record CourseFaqResponse(
        Long id,
        String question,
        String answer,
        Integer position
) {
}