package app.lms.block.dto;

public record UpdateBlockRequest(

        String title,

        String content,

        Boolean isPublished

) {
}
