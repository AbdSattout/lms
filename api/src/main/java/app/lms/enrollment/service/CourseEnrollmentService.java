package app.lms.enrollment.service;

import app.lms.block.model.Block;
import app.lms.block.repository.BlockRepository;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.CourseBan.repository.CourseBanRepository;
import app.lms.enrollment.dto.EnrollmentResponse;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.model.CourseEnrollment;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.course.enums.CourseStatus;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.gamification.dto.GamificationAwardResponse;
import app.lms.gamification.enums.XPEventType;
import app.lms.gamification.service.GamificationService;
import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.model.Organization;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationJoinRequest.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.plan.annotation.ConsumesPlanUsage;
import app.lms.plan.enums.PlanUsageType;
import app.lms.progress.dto.SubmitBlockAnswerResponse;
import app.lms.progress.repository.BlockProgressRepository;
import app.lms.roadmap.service.RoadmapFollowProgressService;
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

    private final RoadmapFollowProgressService roadmapFollowProgressService;

    private final CourseBanRepository courseBanRepository;

    @Transactional
    @ConsumesPlanUsage(PlanUsageType.COURSE_ENROLLMENT)
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

        if (courseBanRepository.existsByCourseIdAndUserId(
                course.getId(),
                user.getId())) {

            throw new ForbiddenException(
                    "You are banned from this course."
            );
        }

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

        CourseEnrollment existingEnrollment =
                enrollmentRepository
                        .findByUserIdAndCourseId(
                                user.getId(),
                                courseId
                        )
                        .orElse(null);

        if (
                existingEnrollment != null &&
                        existingEnrollment.getStatus() == EnrollmentStatus.ACTIVE
        ) {
            throw new ConflictException(
                    "Already enrolled"
            );
        }

            if (!member) {
                throw new ForbiddenException(
                        "Join to the organization first"
                );
            }


        if (existingEnrollment != null) {

            existingEnrollment.setStatus(
                    EnrollmentStatus.ACTIVE
            );

            roadmapFollowProgressService.refreshForCourse(
                    course.getId(),
                    user
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

        roadmapFollowProgressService.refreshForCourse(
                courseId,
                user
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

    public void completeEnrollment(
            CourseEnrollment enrollment
    ) {

        enrollment.setStatus(
                EnrollmentStatus.COMPLETED
        );

        if (enrollment.getCompletedAt() == null) {
            enrollment.setCompletedAt(
                    LocalDateTime.now()
            );
        }

        roadmapFollowProgressService.refreshForCourse(
                enrollment.getCourse().getId(),
                enrollment.getUser()
        );
    }

    @Transactional
    public void unenrollFromOrganization(
            Long organizationId,
            User user
    ) {

        List<CourseEnrollment> enrollments =
                enrollmentRepository
                        .findByUserIdAndCourseOrganizationIdAndStatus(
                                user.getId(),
                                organizationId,
                                EnrollmentStatus.ACTIVE
                        );

        for (CourseEnrollment enrollment : enrollments) {

            enrollment.setStatus(
                    EnrollmentStatus.DROPPED
            );

            roadmapFollowProgressService.refreshForCourse(
                    enrollment.getCourse().getId(),
                    user
            );
        }
    }
}
