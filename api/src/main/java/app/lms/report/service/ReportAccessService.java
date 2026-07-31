package app.lms.report.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.repository.CourseRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.post.repository.CommentRepository;
import app.lms.post.repository.PostRepository;
import app.lms.post.service.PostAccessService;
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


    public void validateTarget(
            ReportTargetType targetType,
            Long targetId
    ) {

        switch (targetType) {

            case USER ->
                    userRepository.findById(targetId).orElseThrow(() -> new UsernameNotFoundException(
                            "user not found"
                    ));

            case POST ->
                    postRepository.findById(targetId).orElseThrow(() -> new NotFoundException(
                            "post not found"
                    ));

            case COURSE ->
                    courseRepository.findById(targetId).orElseThrow(() -> new NotFoundException(
                            "course not found"
                    ));

            case ORGANIZATION ->
                    organizationRepository.findById(targetId).orElseThrow(() -> new NotFoundException(
                            "organization not found"
                    ));

            case COMMENT -> {
                commentRepository.findById(targetId).orElseThrow(() -> new NotFoundException(
                        "comment not found"
                ));
            }
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
