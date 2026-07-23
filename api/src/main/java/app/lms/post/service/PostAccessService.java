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
        organizationMemberAccessService.getMember(
                organization.getId(),
                user.getId()
        );
    }

    public void validateEditable(
            Post post,
            User user
    ) {

        organizationAccessService.getManageableOrganization(
                post.getOrganization().getSlug(),
                user
        );
    }

    public void validateCourseAccess(
            Post post,
            User user
    ) {

        if (post.getCourse() == null) {
            return;
        }

        if (organizationMemberAccessService.isManager(
                post.getOrganization().getId(),
                user.getId()
        )) {
            return;
        }

        courseEnrollmentAccessService.validateEnrolled(
                post.getCourse().getId(),
                user
        );
    }
}