package app.lms.post.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
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
    private final OrganizationAccessService organizationAccessService;
    private final CourseRepository courseRepository;

    @Transactional
    public PostResponse create(
            String slug,
            CreatePostRequest request,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        Course course = null;

        if (request.courseId() != null) {

            course =
                    courseAccessService
                            .getEditableCourse(
                                    request.courseId(),
                                    user
                            );

            if (!course.getOrganization().getId()
                    .equals(organization.getId())) {

                throw new ConflictException(
                        "Course does not belong to organization"
                );
            }
        }

        Post post =
                Post.builder()
                        .title(request.title())
                        .content(request.content())
                        .author(user)
                        .organization(organization)
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

    public Page<PostResponse> getOrganizationPosts(String slug, Pageable pageable) {
        Organization organization =
                organizationAccessService.getBySlug(slug);

        return postRepository
                .findByOrganizationId(
                        organization.getId(),
                        pageable
                )
                .map(postMapper::toResponse);
    }

    public PostResponse getById(Long postId) {
        Post post = postAccessService.getById(postId);
        return postMapper.toResponse(post);
    }

    public Page<PostResponse> getCoursePosts(
            Long courseId,
            Pageable pageable
    ) {
        courseRepository.findById(courseId)
                .orElseThrow(() -> new NotFoundException("Course not found"));



        Page<Post> posts = postRepository
                .findByCourseId(
                        courseId,
                        pageable
                );
        if (posts.isEmpty())
            throw new NotFoundException("No posts found for this course");

        return posts.map(postMapper::toResponse);
    }

}
