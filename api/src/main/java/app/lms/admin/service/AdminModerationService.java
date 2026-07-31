package app.lms.admin.service;

import app.lms.admin.dto.BanRequest;
import app.lms.admin.model.Admin;
import app.lms.common.exception.BadRequestException;
import app.lms.course.CourseBan.model.CourseBan;
import app.lms.course.CourseBan.model.CourseModeration;
import app.lms.course.CourseBan.repository.CourseBanRepository;
import app.lms.course.CourseBan.repository.CourseModerationRepository;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.enrollment.service.CourseEnrollmentService;
import app.lms.organization.OrganizationBan.model.OrganizationBan;
import app.lms.organization.OrganizationBan.model.OrganizationModeration;
import app.lms.organization.OrganizationBan.repository.OrganizationBanRepository;
import app.lms.organization.OrganizationBan.repository.OrganizationModerationRepository;
import app.lms.organization.model.Organization;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Transactional
public class AdminModerationService {

    private final AdminModerationAccessService accessService;

    private final OrganizationBanRepository organizationBanRepository;
    private final CourseBanRepository courseBanRepository;

    private final CourseEnrollmentService courseEnrollmentService;

    private final CourseModerationRepository courseModerationRepository;
    private final OrganizationModerationRepository organizationModerationRepository;

    public void banFromOrganization(
            Long organizationId,
            Long userId,
            BanRequest request,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );


        accessService.validateOrganizationNotBanned(
                organization,
                user
        );


        courseEnrollmentService.unenrollFromOrganization(
                organization.getId(),
                user
        );

        accessService.removeMembership(
                organization,
                user
        );

        OrganizationBan ban =
                OrganizationBan.builder()
                        .organization(organization)
                        .user(user)
                        .bannedByAppAdmins(admin)
                        .reason(request.reason())
                        .build();

        organizationBanRepository.save(
                ban
        );
    }

    public void unbanFromOrganization(
            Long organizationId,
            Long userId,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        OrganizationBan ban =
                accessService.getOrganizationBan(
                        organization,
                        user
                );

        organizationBanRepository.delete(
                ban
        );

    }

    public void banFromCourse(
            Long courseId,
            Long userId,
            BanRequest request,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        Course course =
                accessService.getCourse(
                        courseId
                );


        accessService.validateCourseNotBanned(
                course,
                user
        );

        courseEnrollmentService.unenroll(
                course.getId(),
                user
        );

        CourseBan ban =
                CourseBan.builder()
                        .course(course)
                        .user(user)
                        .bannedByAppAdmins(admin)
                        .reason(request.reason())
                        .build();

        courseBanRepository.save(
                ban
        );

    }

    public void unbanFromCourse(
            Long courseId,
            Long userId,
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        User user =
                accessService.getUser(
                        userId
                );

        Course course =
                accessService.getCourse(
                        courseId
                );

        CourseBan ban =
                accessService.getCourseBan(
                        course,
                        user
                );

        courseBanRepository.delete(
                ban
        );

    }

    public void banCourse(
            Long courseId,
            BanRequest request,
            Long adminId
    ){
        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);


        Course course =
                accessService.getCourse(
                        courseId
                );

        accessService.validateCourseModerationNotBanned(
                course
        );

        courseModerationRepository.save(
                CourseModeration.builder()
                        .course(course)
                        .bannedBy(admin)
                        .reason(request.reason())
                        .build()
        );

    }

    public void unbanCourse(
            Long courseId,
            Long adminId
    ){
        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        Course course =
                accessService.getCourse(
                        courseId
                );

        CourseModeration ban =
                accessService.getCourseModerationBan(
                        course
                );

        courseModerationRepository.delete(
                ban
        );

    }

    public void banOrganization(
            Long organizationId,
            BanRequest request,
            Long adminId
    ){
        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        accessService.validateOrganizationModerationNotBanned(
                organization
        );

        organizationModerationRepository.save(
                OrganizationModeration.builder()
                        .organization(organization)
                        .bannedBy(admin)
                        .reason(request.reason())
                        .build()
        );

    }

    public void unbanOrganization(
            Long organizationId,
            Long adminId
    ){
        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(admin);

        Organization organization =
                accessService.getOrganization(
                        organizationId
                );

        OrganizationModeration ban =
                accessService.getOrganizationModerationBan(
                        organization
                );

        organizationModerationRepository.delete(
                ban
        );

    }


}
