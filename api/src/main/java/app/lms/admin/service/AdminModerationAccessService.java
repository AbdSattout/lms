package app.lms.admin.service;

import app.lms.admin.enums.AdminRole;
import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.CourseBan.model.CourseBan;
import app.lms.course.CourseBan.model.CourseModeration;
import app.lms.course.CourseBan.repository.CourseBanRepository;
import app.lms.course.CourseBan.repository.CourseModerationRepository;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.OrganizationBan.model.OrganizationBan;
import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import app.lms.organization.OrganizationBan.repository.OrganizationBanRepository;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminModerationAccessService {

    private final UserRepository userRepository;
    private final AdminRepository adminRepository;
    private final OrganizationRepository organizationRepository;
    private final CourseRepository courseRepository;
    private final OrganizationBanRepository organizationBanRepository;
    private final CourseBanRepository courseBanRepository;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final CourseModerationRepository courseModerationRepository;
    private final OrganizationModerationRepository organizationModerationRepository;

    public User getUser(
            Long userId
    ) {

        return userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "User not found"
                        )
                );
    }

    public Admin getAdmin(
            Long adminId
    ) {

        return adminRepository
                .findById(adminId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Admin not found"
                        )
                );
    }

    public void validateAdmin(
            Admin admin
    ) {
        boolean allowed =
                admin.getRole() == AdminRole.SUPER_ADMIN
                        || admin.getRole() == AdminRole.MODERATOR;

        if (!allowed) {
            throw new ForbiddenException(
                    "Access denied"
            );
        }

    }

    public Organization getOrganization(
            Long organizationId
    ) {

        return organizationRepository
                .findById(organizationId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization not found"
                        )
                );
    }

    public Course getCourse(
            Long courseId
    ) {

        return courseRepository
                .findById(courseId)
                .orElseThrow(() ->
                        new NotFoundException(
                                "Course not found"
                        )
                );
    }

    public void validateOrganizationNotBanned(
            Organization organization,
            User user
    ) {

        if (
                organizationBanRepository.existsByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
        ) {

            throw new BadRequestException(
                    "User is already banned from this organization"
            );
        }

    }

    public void validateCourseNotBanned(
            Course course,
            User user
    ) {

        if (
                courseBanRepository.existsByCourseIdAndUserId(
                        course.getId(),
                        user.getId()
                )
        ) {

            throw new BadRequestException(
                    "User is already banned from this course"
            );
        }

    }

    public OrganizationBan getOrganizationBan(
            Organization organization,
            User user
    ) {

        return organizationBanRepository
                .findByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Ban not found"
                        )
                );
    }

    public CourseBan getCourseBan(
            Course course,
            User user
    ) {

        return courseBanRepository
                .findByCourseIdAndUserId(
                        course.getId(),
                        user.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Ban not found"
                        )
                );
    }
    public void removeMembership(
            Organization organization,
            User user
    ) {

        organizationMemberRepository
                .findByOrganizationIdAndUserId(
                        organization.getId(),
                        user.getId()
                )
                .ifPresent(
                        organizationMemberRepository::delete
                );

    }

    public CourseModeration getCourseModerationBan(
            Course course
    ) {

        return courseModerationRepository
                .findByCourseId(
                        course.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Ban not found"
                        )
                );
    }

    public void validateCourseModerationNotBanned(
            Course course
    ) {

        if (
                courseModerationRepository.existsByCourseId(
                        course.getId()
                )
        ) {

            throw new BadRequestException(
                    "Course is already banned "
            );
        }

    }

    public OrganizationModeration getOrganizationModerationBan(
            Organization organization
    ) {

        return organizationModerationRepository
                .findByOrganizationId(
                        organization.getId()
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Ban not found"
                        )
                );
    }

    public void validateOrganizationModerationNotBanned(
            Organization organization
    ) {

        if (
                organizationModerationRepository.existsByOrganizationId(
                        organization.getId()
                )
        ) {

            throw new BadRequestException(
                    "Organization is already banned "
            );
        }

    }

}
