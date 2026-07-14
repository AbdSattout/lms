package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;

public record PostResponse(

        long id,

        String title,

        String content,

        AuthorResponse author,

        Long organizationId,

        long courseId,

        Long likesCount,

        Long commentsCount,

        BaseEntityResponse baseEntity
) {
}
