package app.lms.analytics.user.service;

import app.lms.certificate.repository.CertificateRepository;
import app.lms.common.exception.NotFoundException;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.analytics.user.dto.UserOverviewResponse;
import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.gamification.service.UserActivityService;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class UserOverviewService {

    private final OrganizationMemberRepository organizationMemberRepository;

    private final CourseEnrollmentRepository courseEnrollmentRepository;

    private final CertificateRepository certificateRepository;

    private final UserProgressRepository userProgressRepository;

    private final UserActivityService userActivityService;

    private final RoadmapFollowerRepository roadmapFollowerRepository;

    public UserOverviewResponse getOverview(
            User user
    ) {

        UserProgress progress =
                userProgressRepository
                        .findByUserId(user.getId())
                        .orElseThrow(() -> new NotFoundException(
                                "Progress not found"
                        ));

        UserStreakResponse streak =
                userActivityService.getStreak(user);

        return UserOverviewResponse.builder()

                .organizationsCount(
                        organizationMemberRepository
                                .countByUserId(user.getId())
                )

                .enrolledCoursesCount(
                        courseEnrollmentRepository
                                .countByUserIdAndStatus(
                                        user.getId(),
                                        EnrollmentStatus.ACTIVE
                                )
                )

                .completedCoursesCount(
                        courseEnrollmentRepository
                                .countByUserIdAndStatus(
                                        user.getId(),
                                        EnrollmentStatus.COMPLETED
                                )
                )

                .followingRoadmapsCount(
                        roadmapFollowerRepository.countActiveByUserId(
                                user.getId()
                        )
                )

                .completedRoadmapsCount(
                        roadmapFollowerRepository.countByUserIdAndStatus(
                                user.getId(),
                                RoadmapFollowStatus.COMPLETED
                        )
                )

                .certificatesCount(
                        certificateRepository
                                .countByUserId(
                                        user.getId()
                                )
                )

                .totalXp(progress.getTotalXp())

                .currentLevel(
                        progress.getCurrentLevel()
                                .getLevelNumber()
                )

                .currentStreak(
                        streak.currentStreak()
                )

                .longestStreak(
                        streak.longestStreak()
                )


                .build();
    }

}
