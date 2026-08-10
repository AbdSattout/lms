package app.lms.post.service;

import app.lms.enrollment.service.CourseEnrollmentAccessService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.post.model.Post;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class PostAccessService {

    private final OrganizationAccessService organizationAccessService;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

    public void validateMember(
            Organization organization,
            User user
    ) {
        validateOrganizationAccess(
                organization,
                user
        );

        organizationMemberAccessService.getMember(
                organization.getId(),
                user.getId()
        );
    }

    public void validateEditable(
            Post post,
            User user
    ) {

        validateOrganizationAccess(
                post,
                user
        );

        organizationAccessService.getManageableOrganization(
                post.getOrganization().getSlug(),
                user
        );
    }

    public void validateCourseAccess(
            Post post,
            User user
    ) {

        validateOrganizationAccess(
                post,
                user
        );

        if (post.getCourse() == null) {
            return;
        }

        if (organizationMemberAccessService.isManager(
                post.getOrganization().getId(),
                user.getId()
        )) {
            return;
        }

        organizationMemberAccessService.getMember(
                post.getOrganization().getId(),
                user.getId()
        );

        courseEnrollmentAccessService.validateEnrolled(
                post.getCourse().getId(),
                user
        );
    }

    public void validateInteractionAccess(
            Post post,
            User user
    ) {

        validateMember(
                post.getOrganization(),
                user
        );

        validateCourseAccess(
                post,
                user
        );
    }

    public void validateOrganizationAccess(
            Organization organization,
            User user
    ) {

        organizationAccessService
                .validateNotBanned(
                        organization
                );

        organizationAccessService
                .validateUserNotBannedFromOrg(
                        organization,
                        user
                );
    }

    private void validateOrganizationAccess(
            Post post,
            User user
    ) {

        validateOrganizationAccess(
                post.getOrganization(),
                user
        );
    }
}
