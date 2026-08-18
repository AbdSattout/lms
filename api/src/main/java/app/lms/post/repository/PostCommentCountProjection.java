package app.lms.post.repository;

public interface PostCommentCountProjection {

    Long getPostId();

    Long getCommentCount();
}
