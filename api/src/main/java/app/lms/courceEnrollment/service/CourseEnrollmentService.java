package app.lms.courceEnrollment.service;

import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.organization.enums.Role;
import app.lms.courceEnrollment.enums.XPEventType;
import app.lms.course.model.Course;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.model.XPEvent;
import app.lms.course.repository.CourseRepository;
import app.lms.block.repository.BlockRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.ProgressRepository;
import app.lms.organization.repository.XPEventRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentService {

    private final CourseRepository courseRepository;

    private final CourseEnrollmentRepository
            enrollmentRepository;

    private final OrganizationMemberRepository
            memberRepository;

    private final XPEventRepository xpEventRepository;

    private final BlockRepository blockRepository;

    private final ProgressRepository progressRepository;

    @Transactional
    public EnrollmentResponse enroll(

            Long courseId,
            User user
    ) {

        Course course =
                courseRepository.findById(courseId)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Course not found"
                                )
                        );

        boolean alreadyEnrolled =
                enrollmentRepository
                        .existsByUserIdAndCourseId(
                                user.getId(),
                                courseId
                        );

        if (alreadyEnrolled) {

            throw new IllegalStateException(
                    "Already enrolled"
            );
        }

        CourseEnrollment enrollment =
                CourseEnrollment.builder()
                        .course(course)
                        .user(user)
                        .status(EnrollmentStatus.ACTIVE)
                        .progressPercentage(0)
                        .build();

        enrollmentRepository.save(enrollment);

        Organization organization =
                course.getOrganization();

        boolean isMember =
                memberRepository
                        .existsByOrganizationIdAndUserId(
                                organization.getId(),
                                user.getId()
                        );

        if (!isMember) {

            OrganizationMember member =
                    OrganizationMember.builder()
                            .organization(organization)
                            .user(user)
                            .role(
                                    Role.STUDENT
                            )
                            .build();

            memberRepository.save(member);
        }

        XPEvent xpEvent =
                XPEvent.builder()
                        .user(user)
                        .type(
                                XPEventType.COURSE_ENROLL
                        )
                        .referenceId(course.getId())
                        .amount(1)
                        .build();

        xpEventRepository.save(xpEvent);

        return EnrollmentResponse.builder()
                .courseId(course.getId())
                .courseTitle(course.getTitle())
                .enrolledAt(
                        enrollment.getEnrolledAt()
                )
                .build();
    }

    @Transactional
    public void unenroll(
            Long courseId,
            User user
    ) {

        CourseEnrollment enrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                user.getId(),
                                courseId
                        )
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Enrollment not found"
                                )
                        );

        enrollment.setStatus(
                EnrollmentStatus.DROPPED
        );
    }


}
