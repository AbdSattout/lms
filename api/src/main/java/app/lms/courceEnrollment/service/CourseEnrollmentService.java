package app.lms.courceEnrollment.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.enums.XPEventType;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.organization.enums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.model.XPEvent;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.XPEventRepository;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentService {

    private final CourseRepository courseRepository;

    private final CourseEnrollmentRepository enrollmentRepository;

    private final OrganizationMemberRepository memberRepository;

    private final XPEventRepository xpEventRepository;

    private final BlockRepository blockRepository;

    private final BlockProgressRepository blockProgressRepository;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

    @Transactional
    public EnrollmentResponse enroll(
            Long courseId,
            User user
    ) {

        Course course =
                courseRepository
                        .findById(courseId)
                        .orElseThrow(() ->
                                new NotFoundException(
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

        addStudentToOrganizationIfNeeded(
                course.getOrganization(),
                user
        );

        createEnrollXpEvent(
                course,
                user
        );

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
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        enrollment.setStatus(
                EnrollmentStatus.DROPPED
        );
    }

    @Transactional
    public void updateProgressAfterCorrectAnswer(
            Block currentBlock,
            SubmitBlockAnswerResponse nextStep,
            User user
    ) {

        Long courseId =
                currentBlock.getLesson()
                        .getChapter()
                        .getCourse()
                        .getId();

        CourseEnrollment enrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                user.getId(),
                                courseId
                        )
                        .orElseThrow(() ->
                                new ForbiddenException(
                                        "You are not enrolled in this course"
                                )
                        );

        if (Boolean.TRUE.equals(nextStep.courseCompleted())) {

            enrollment.setProgressPercentage(100);

            if (enrollment.getCompletedAt() == null) {
                enrollment.setCompletedAt(
                        LocalDateTime.now()
                );
            }

            return;
        }

        Block nextBlock =
                blockRepository
                        .findById(
                                nextStep.nextBlockId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Next block not found"
                                )
                        );

        enrollment.setLastAccessedLesson(
                nextBlock.getLesson()
        );

        enrollment.setLastAccessedBlock(
                nextBlock
        );

        enrollment.setProgressPercentage(
                calculateProgressPercentage(
                        courseId,
                        user.getId()
                )
        );
    }

    private Integer calculateProgressPercentage(
            Long courseId,
            Long userId
    ) {

        long completedBlocks =
                blockProgressRepository
                        .countByUserIdAndBlockLessonChapterCourseIdAndCompletedTrue(
                                userId,
                                courseId
                        );

        long totalBlocks =
                blockRepository
                        .countByLessonChapterCourseId(
                                courseId
                        );

        if (totalBlocks == 0) {
            return 0;
        }

        return (int) Math.round(
                completedBlocks * 100.0 / totalBlocks
        );
    }

    private void addStudentToOrganizationIfNeeded(
            Organization organization,
            User user
    ) {

        boolean isMember =
                memberRepository
                        .existsByOrganizationIdAndUserId(
                                organization.getId(),
                                user.getId()
                        );

        if (isMember) {
            return;
        }

        OrganizationMember member =
                OrganizationMember.builder()
                        .organization(organization)
                        .user(user)
                        .role(Role.STUDENT)
                        .build();

        memberRepository.save(member);
    }

    private void createEnrollXpEvent(
            Course course,
            User user
    ) {

        XPEvent xpEvent =
                XPEvent.builder()
                        .user(user)
                        .type(XPEventType.COURSE_ENROLL)
                        .referenceId(course.getId())
                        .amount(1)
                        .build();

        xpEventRepository.save(xpEvent);
    }
}