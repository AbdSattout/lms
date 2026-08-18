package app.lms.report.mapper;

import app.lms.admin.mapper.AdminMapper;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.report.dto.ReportResponse;
import app.lms.report.dto.ReportTargetResponse;
import app.lms.report.model.Report;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.post.model.Comment;
import app.lms.post.model.Post;
import app.lms.post.repository.CommentRepository;
import app.lms.post.repository.PostRepository;
import app.lms.user.model.User;
import app.lms.user.mapper.UserMapper;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ReportMapper {

    private final UserMapper userMapper;
    private final AdminMapper adminMapper;
    private final UserRepository userRepository;
    private final PostRepository postRepository;
    private final CommentRepository commentRepository;
    private final CourseRepository courseRepository;
    private final OrganizationRepository organizationRepository;

    public ReportResponse   toResponse(
            Report report
    ) {

        return new ReportResponse(

                report.getId(),

                userMapper.toResponse(
                        report.getReporter()
                ),

                report.getTargetType(),

                targetResponse(report),

                report.getReason(),

                report.getStatus(),

                report.getAdminNote(),

                adminMapper.toResponse(
                        report.getReviewedBy()
                ),

                BaseEntityResponse.from(report),

                report.getReviewedAt()
        );
    }

    private ReportTargetResponse targetResponse(
            Report report
    ) {

        return switch (report.getTargetType()) {
            case USER -> userTarget(report.getTargetId());
            case POST -> postTarget(report.getTargetId());
            case COMMENT -> commentTarget(report.getTargetId());
            case COURSE -> courseTarget(report.getTargetId());
            case ORGANIZATION -> organizationTarget(report.getTargetId());
        };
    }

    private ReportTargetResponse userTarget(
            Long userId
    ) {

        boolean exists =
                userRepository.existsById(userId);

        return new ReportTargetResponse(
                userId,
                null,
                null,
                null,
                null,
                exists
        );
    }

    private ReportTargetResponse postTarget(
            Long postId
    ) {

        return postRepository
                .findById(postId)
                .map(this::postTarget)
                .orElseGet(() ->
                        new ReportTargetResponse(
                                null,
                                null,
                                null,
                                postId,
                                null,
                                false
                        )
                );
    }

    private ReportTargetResponse postTarget(
            Post post
    ) {

        return new ReportTargetResponse(
                id(post.getAuthor()),
                id(post.getOrganization()),
                id(post.getCourse()),
                post.getId(),
                null,
                true
        );
    }

    private ReportTargetResponse commentTarget(
            Long commentId
    ) {

        return commentRepository
                .findById(commentId)
                .map(this::commentTarget)
                .orElseGet(() ->
                        new ReportTargetResponse(
                                null,
                                null,
                                null,
                                null,
                                commentId,
                                false
                        )
                );
    }

    private ReportTargetResponse commentTarget(
            Comment comment
    ) {

        Post post =
                comment.getPost();

        return new ReportTargetResponse(
                id(comment.getAuthor()),
                post != null
                        ? id(post.getOrganization())
                        : null,
                post != null
                        ? id(post.getCourse())
                        : null,
                post != null
                        ? post.getId()
                        : null,
                comment.getId(),
                true
        );
    }

    private ReportTargetResponse courseTarget(
            Long courseId
    ) {

        return courseRepository
                .findById(courseId)
                .map(this::courseTarget)
                .orElseGet(() ->
                        new ReportTargetResponse(
                                null,
                                null,
                                courseId,
                                null,
                                null,
                                false
                        )
                );
    }

    private ReportTargetResponse courseTarget(
            Course course
    ) {

        return new ReportTargetResponse(
                null,
                id(course.getOrganization()),
                course.getId(),
                null,
                null,
                true
        );
    }

    private ReportTargetResponse organizationTarget(
            Long organizationId
    ) {

        return organizationRepository
                .findById(organizationId)
                .map(this::organizationTarget)
                .orElseGet(() ->
                        new ReportTargetResponse(
                                null,
                                organizationId,
                                null,
                                null,
                                null,
                                false
                        )
                );
    }

    private ReportTargetResponse organizationTarget(
            Organization organization
    ) {

        return new ReportTargetResponse(
                id(organization.getOwner()),
                organization.getId(),
                null,
                null,
                null,
                true
        );
    }

    private Long id(
            User user
    ) {

        return user != null
                ? user.getId()
                : null;
    }

    private Long id(
            Organization organization
    ) {

        return organization != null
                ? organization.getId()
                : null;
    }

    private Long id(
            Course course
    ) {

        return course != null
                ? course.getId()
                : null;
    }

}
