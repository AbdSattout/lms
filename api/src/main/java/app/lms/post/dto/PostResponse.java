package app.lms.post.dto;

import java.time.LocalDateTime;

public record PostResponse(

        long id,

        String title,

        String content,

        AuthorResponse author,

        Long organizationId,

        long courseId,

        Long likesCount,

        Long commentsCount,

        LocalDateTime createdAt

) {
}
