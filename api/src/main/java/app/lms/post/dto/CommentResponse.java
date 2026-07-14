package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;

import java.time.LocalDateTime;

public record CommentResponse(

        long id,

        String content,

        AuthorResponse author,

        Long parentCommentId,

        LocalDateTime createdAt,

        LocalDateTime updatedAt,

        BaseEntityResponse baseEntity

) {
}
