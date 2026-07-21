package app.lms.post.dto;

import app.lms.common.dto.BaseEntityResponse;

public record PostResponse(

        long id,

        String title,

        String content,

        AuthorResponse author,

        Long organizationId,

        Long courseId,

        Long commentCount,

        Long likeCount,

        BaseEntityResponse baseEntity
) {
}
