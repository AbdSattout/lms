package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;

public record CommentResponse(

        long id,

        String content,

        AuthorResponse author,

        Long parentCommentId,

        BaseEntityResponse baseEntity

) {
}
