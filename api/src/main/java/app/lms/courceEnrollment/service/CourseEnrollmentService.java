package app.lms.courceEnrollment.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.courceEnrollment.dto.EnrollmentResponse;
import app.lms.courceEnrollment.enums.EnrollmentStatus;
import app.lms.courceEnrollment.model.CourseEnrollment;
import app.lms.courceEnrollment.repository.CourseEnrollmentRepository;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.service.GamificationService;
import app.lms.organization.enums.JoinRequestStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationJoinRequest;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CourseEnrollmentService {

    private static final int COURSE_ENROLL_XP = 10;

    private final CourseRepository courseRepository;

    private final CourseEnrollmentRepository enrollmentRepository;

    private final OrganizationMemberRepository memberRepository;

    private final GamificationService gamificationService;

    private final BlockRepository blockRepository;

    private final BlockProgressRepository blockProgressRepository;

    private final CourseEnrollmentAccessService courseEnrollmentAccessService;

    private final OrganizationJoinRequestRepository joinRequestRepository;

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

        if (course.getStatus() != CourseStatus.PUBLISHED) {
            throw new ConflictException(
                    "Course is not published yet"
            );
        }

        Organization organization =
                course.getOrganization();

        Optional<OrganizationMember> existingMember =
                memberRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                user.getId()
                        );

        validateCanEnrollAsStudent(
                existingMember
        );

        boolean member =
                existingMember.isPresent();

        if (organization.getVisibility() == Visibility.PUBLIC) {

            if (!member) {
                OrganizationMember organizationMember =
                        OrganizationMember.builder()
                                .organization(organization)
                                .user(user)
                                .role(Role.STUDENT)
                                .build();

                memberRepository.save(
                        organizationMember
                );
            }

        } else {

            if (!member) {
                boolean pending =
                        joinRequestRepository
                                .existsByOrganizationIdAndUserIdAndStatus(
                                        organization.getId(),
                                        user.getId(),
                                        JoinRequestStatus.PENDING
                                );

                if (pending) {
                    throw new ConflictException(
                            "Join request already sent"
                    );
                }

                OrganizationJoinRequest request =
                        OrganizationJoinRequest.builder()
                                .organization(organization)
                                .user(user)
                                .status(JoinRequestStatus.PENDING)
                                .build();

                joinRequestRepository.save(
                        request
                );

                throw new ForbiddenException(
                        "Organization is private. Join request sent."
                );
            }
        }

        CourseEnrollment existingEnrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                user.getId(),
                                courseId
                        )
                        .orElse(null);

        if (existingEnrollment != null) {

            if (existingEnrollment.getStatus() == EnrollmentStatus.ACTIVE) {
                throw new ConflictException(
                        "Already enrolled"
                );
            }

            existingEnrollment.setStatus(
                    EnrollmentStatus.ACTIVE
            );

            return EnrollmentResponse.builder()
                    .courseId(course.getId())
                    .courseTitle(course.getTitle())
                    .enrolledAt(
                            existingEnrollment.getEnrolledAt()
                    )
                    .rewards(List.of())
                    .build();
        }

        CourseEnrollment enrollment =
                CourseEnrollment.builder()
                        .course(course)
                        .user(user)
                        .status(EnrollmentStatus.ACTIVE)
                        .progressPercentage(0)
                        .build();

        enrollmentRepository.save(
                enrollment
        );

        GamificationAwardResponse reward =
                gamificationService.awardXp(
                        user,
                        XPEventType.COURSE_ENROLL,
                        course.getId(),
                        COURSE_ENROLL_XP
                );

        return EnrollmentResponse.builder()
                .courseId(course.getId())
                .courseTitle(course.getTitle())
                .enrolledAt(
                        enrollment.getEnrolledAt()
                )
                .rewards(
                        reward.awarded()
                                ? List.of(reward)
                                : List.of()
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
                courseEnrollmentAccessService
                        .getEnrollment(
                                courseId,
                                user
                        );

        enrollment.setProgressPercentage(
                calculateProgressPercentage(
                        courseId,
                        user.getId()
                )
        );

        switch (nextStep.nextType()) {

            case COURSE_COMPLETED -> {

                enrollment.setProgressPercentage(
                        100
                );

                enrollment.setCurrentLesson(
                        currentBlock.getLesson()
                );

                enrollment.setCurrentBlock(
                        currentBlock
                );

                if (enrollment.getCompletedAt() == null) {
                    enrollment.setCompletedAt(
                            LocalDateTime.now()
                    );
                }
            }

            case QUIZ -> {

                enrollment.setCurrentLesson(
                        currentBlock.getLesson()
                );

                enrollment.setCurrentBlock(
                        currentBlock
                );
            }

            case BLOCK -> {

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

                enrollment.setCurrentLesson(
                        nextBlock.getLesson()
                );

                enrollment.setCurrentBlock(
                        nextBlock
                );
            }

            case INCORRECT -> {

            }
        }
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


    private void validateCanEnrollAsStudent(
            Optional<OrganizationMember> existingMember
    ) {

        if (existingMember.isEmpty()) {
            return;
        }

        Role role =
                existingMember
                        .get()
                        .getRole();

        if (role == Role.OWNER || role == Role.ADMIN) {
            throw new ForbiddenException(
                    "Organization owners and admins cannot enroll as students"
            );
        }
    }

    public boolean isEnrolled(
            Long courseId,
            User user
    ) {

        return enrollmentRepository.existsByCourseIdAndUserId(
                courseId,
                user.getId()
        );
    }
}
