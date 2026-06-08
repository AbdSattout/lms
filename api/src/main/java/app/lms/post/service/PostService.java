package app.lms.post.service;

import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.post.dto.CreatePostRequest;
import app.lms.post.dto.PostResponse;
import app.lms.post.dto.UpdatePostRequest;
import app.lms.post.mapper.PostMapper;
import app.lms.post.model.Post;
import app.lms.post.repository.PostRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostService {

    private final CourseAccessService courseAccessService;
    private final PostRepository postRepository;
    private final PostMapper postMapper;
    private final PostAccessService postAccessService;

    @Transactional
    public PostResponse create(
            Long courseId,
            CreatePostRequest request,
            User user
    ) {

        Course course =
                courseAccessService
                        .getEditableCourse(
                                courseId,
                                user
                        );

        Post post =
                Post.builder()
                        .title(request.title())
                        .content(request.content())
                        .author(user)
                        .course(course)
                        .likesCount(0L)
                        .commentsCount(0L)
                        .build();

        postRepository.save(post);

        return postMapper.toResponse(
                post
        );
    }

    @Transactional
    public PostResponse update(
            Long postId,
            UpdatePostRequest request,
            User user
    ) {

        Post post =
                postAccessService
                        .getEditablePost(
                                postId,
                                user
                        );

        if (request.title() != null) {
            post.setTitle(
                    request.title()
            );
        }

        if (request.content() != null) {
            post.setContent(
                    request.content()
            );
        }

        return postMapper.toResponse(
                post
        );
    }

    @Transactional
    public void delete(
            Long postId,
            User user
    ) {

        Post post =
                postAccessService
                        .getEditablePost(
                                postId,
                                user
                        );

        postRepository.delete(post);
    }

    public Page<PostResponse> getCoursePosts(Long courseId, Pageable pageable) {
        return postRepository.findByCourseId(courseId, pageable)
                .map(postMapper::toResponse);
    }

    public PostResponse getById(Long postId) {
        Post post = postAccessService.getById(postId);
        return postMapper.toResponse(post);
    }

}
