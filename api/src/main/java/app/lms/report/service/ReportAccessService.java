package app.lms.report.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.post.model.Comment;
import app.lms.post.model.Post;
import app.lms.post.repository.CommentRepository;
import app.lms.post.repository.PostRepository;
import app.lms.report.dto.CreateReportRequest;
import app.lms.report.enums.ReportTargetType;
import app.lms.report.model.Report;
import app.lms.report.repository.ReportRepository;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ReportAccessService {

    private final ReportRepository reportRepository;

    private final UserRepository userRepository;

    private final PostRepository postRepository;

    private final CourseRepository courseRepository;

    private final OrganizationRepository organizationRepository;

    private final CommentRepository commentRepository;


    public Report getById(
            Long reportId
    ) {
        return reportRepository.findById(reportId)
                .orElseThrow(() -> new NotFoundException("report not found"));

    }


    public Long resolveTargetId(
            CreateReportRequest request
    ) {

        if (request.targetType() == null) {
            throw new BadRequestException(
                    "targetType is required"
            );
        }

        return switch (request.targetType()) {

            case USER ->
                    resolveUserTarget(request);

            case POST ->
                    resolvePostTarget(request);

            case COURSE ->
                    resolveCourseTarget(request);

            case ORGANIZATION ->
                    resolveOrganizationTarget(request);

            case COMMENT ->
                    resolveCommentTarget(request);
        };

    }

    private Long resolveUserTarget(
            CreateReportRequest request
    ) {

        Long userId =
                requireId(
                        request.userId(),
                        "userId"
                );

        userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "user not found"
                        )
                );

        return userId;
    }

    private Long resolvePostTarget(
            CreateReportRequest request
    ) {

        Long postId =
                requireId(
                        request.postId(),
                        "postId"
                );

        Post post =
                postRepository
                        .findById(postId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "post not found"
                                )
                        );

        requireAndMatch(
                "organizationId",
                request.organizationId(),
                post.getOrganization() != null
                        ? post.getOrganization().getId()
                        : null
        );

        requireAndMatch(
                "userId",
                request.userId(),
                post.getAuthor() != null
                        ? post.getAuthor().getId()
                        : null
        );

        return postId;
    }

    private Long resolveCommentTarget(
            CreateReportRequest request
    ) {

        Long commentId =
                requireId(
                        request.commentId(),
                        "commentId"
                );

        Comment comment =
                commentRepository
                        .findById(commentId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "comment not found"
                                )
                        );

        Post post =
                comment.getPost();

        requireAndMatch(
                "postId",
                request.postId(),
                post != null
                        ? post.getId()
                        : null
        );

        requireAndMatch(
                "organizationId",
                request.organizationId(),
                post != null
                        && post.getOrganization() != null
                        ? post.getOrganization().getId()
                        : null
        );

        requireAndMatch(
                "userId",
                request.userId(),
                comment.getAuthor() != null
                        ? comment.getAuthor().getId()
                        : null
        );

        return commentId;
    }

    private Long resolveCourseTarget(
            CreateReportRequest request
    ) {

        Long courseId =
                requireId(
                        request.courseId(),
                        "courseId"
                );

        Course course =
                courseRepository
                        .findById(courseId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "course not found"
                                )
                        );

        requireAndMatch(
                "organizationId",
                request.organizationId(),
                course.getOrganization() != null
                        ? course.getOrganization().getId()
                        : null
        );

        return courseId;
    }

    private Long resolveOrganizationTarget(
            CreateReportRequest request
    ) {

        Long organizationId =
                requireId(
                        request.organizationId(),
                        "organizationId"
                );

        Organization organization =
                organizationRepository
                        .findById(organizationId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "organization not found"
                                )
                        );

        matchIfProvided(
                "userId",
                request.userId(),
                organization.getOwner() != null
                        ? organization.getOwner().getId()
                        : null
        );

        return organizationId;
    }

    private Long requireId(
            Long id,
            String field
    ) {

        if (id == null) {
            throw new BadRequestException(
                    field + " is required"
            );
        }

        return id;
    }

    private void requireAndMatch(
            String field,
            Long provided,
            Long actual
    ) {

        requireId(
                provided,
                field
        );

        if (!provided.equals(actual)) {
            throw new BadRequestException(
                    field + " does not match the reported target"
            );
        }
    }

    private void matchIfProvided(
            String field,
            Long provided,
            Long actual
    ) {

        if (provided == null) {
            return;
        }

        if (!provided.equals(actual)) {
            throw new BadRequestException(
                    field + " does not match the reported target"
            );
        }
    }


    public void validateNotReportingYourself(
            User reporter,
            ReportTargetType targetType,
            Long targetId
    ) {

        if (targetType != ReportTargetType.USER) {
            return;
        }

        if (reporter.getId().equals(targetId)) {
            throw new IllegalArgumentException(
                    "You cannot report yourself."
            );
        }

    }


    public void validateDuplicate(
            User reporter,
            ReportTargetType targetType,
            Long targetId
    ) {

        boolean exists =
                reportRepository.existsByReporterAndTargetTypeAndTargetId(
                        reporter,
                        targetType,
                        targetId
                );

        if (exists) {
            throw new BadRequestException("Duplicate report");
        }

    }

}
