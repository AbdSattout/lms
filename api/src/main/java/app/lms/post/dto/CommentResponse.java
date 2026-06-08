package app.lms.post.dto;

import java.time.LocalDateTime;

public record CommentResponse(

        long id,

        String content,

        AuthorResponse author,

        Long parentCommentId,

        LocalDateTime createdAt

) {
}
