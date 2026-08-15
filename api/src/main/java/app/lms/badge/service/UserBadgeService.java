package app.lms.badge.service;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.badge.model.UserBadge;
import app.lms.badge.repository.UserBadgeRepository;
import app.lms.certificate.repository.CertificateRepository;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.friend.repository.FriendRepository;
import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.gamification.service.UserActivityService;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserBadgeService {

    private static final String FIRST_STREAK = "FIRST_STREAK";
    private static final String WEEK_STREAK = "WEEK_STREAK";
    private static final String MONTH_STREAK = "MONTH_STREAK";
    private static final String COURSE_FINISHER = "COURSE_FINISHER";
    private static final String FIVE_COURSES = "FIVE_COURSES";
    private static final String CERTIFIED_LEARNER = "CERTIFIED_LEARNER";
    private static final String CONNECTED_LEARNER = "CONNECTED_LEARNER";
    private static final String SOCIAL_LEARNER = "SOCIAL_LEARNER";
    private static final String ROADMAP_FINISHER = "ROADMAP_FINISHER";
    private static final String XP_1000 = "XP_1000";
    private static final String XP_5000 = "XP_5000";
    private static final String LEVEL_5 = "LEVEL_5";
    private static final String LEVEL_10 = "LEVEL_10";
    private static final String LEVEL_20 = "LEVEL_20";

    private final UserBadgeRepository userBadgeRepository;
    private final FriendRepository friendRepository;
    private final CourseEnrollmentRepository courseEnrollmentRepository;
    private final CertificateRepository certificateRepository;
    private final RoadmapFollowerRepository roadmapFollowerRepository;
    private final UserProgressRepository userProgressRepository;
    private final LevelRepository levelRepository;
    private final UserActivityService userActivityService;

    @Transactional
    public List<UserBadgeResponse> awardEarnedBadges(
            User user
    ) {

        List<String> missingCodes =
                missingEligibleCodes(user);

        if (missingCodes.isEmpty()) {
            return List.of();
        }

        userBadgeRepository.insertMissingActiveBadges(
                user.getId(),
                missingCodes
        );

        return userBadgeRepository
                .findAllByUserIdAndBadgeCodeInAndBadgeActiveTrueOrderByBadgeSortOrderAscEarnedAtAsc(
                        user.getId(),
                        missingCodes
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public List<UserBadgeResponse> syncAndListBadges(
            User user
    ) {

        List<String> missingCodes =
                missingEligibleCodes(user);

        if (!missingCodes.isEmpty()) {
            userBadgeRepository.insertMissingActiveBadges(
                    user.getId(),
                    missingCodes
            );
        }

        return userBadgeRepository
                .findAllByUserIdAndBadgeActiveTrueOrderByBadgeSortOrderAscEarnedAtAsc(
                        user.getId()
                )
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private List<String> missingEligibleCodes(
            User user
    ) {

        List<UserBadge> existingBadges =
                userBadgeRepository
                        .findAllByUserIdAndBadgeActiveTrueOrderByBadgeSortOrderAscEarnedAtAsc(
                                user.getId()
                        );

        Set<String> existingCodes =
                existingBadges
                        .stream()
                        .map(userBadge ->
                                userBadge
                                        .getBadge()
                                        .getCode()
                        )
                        .collect(
                                Collectors.toSet()
                        );

        List<String> eligibleCodes =
                eligibleCodes(
                        user
                );

        return eligibleCodes
                .stream()
                .filter(code ->
                        !existingCodes.contains(code)
                )
                .toList();
    }

    private UserBadgeResponse toResponse(
            UserBadge userBadge
    ) {

        return new UserBadgeResponse(
                userBadge
                        .getBadge()
                        .getId(),
                userBadge.getId(),
                userBadge
                        .getBadge()
                        .getCode(),
                userBadge
                        .getBadge()
                        .getTitle(),
                userBadge
                        .getBadge()
                        .getDescription(),
                userBadge
                        .getBadge()
                        .getIconUrl(),
                userBadge.getEarnedAt()
        );
    }

    private List<String> eligibleCodes(
            User user
    ) {

        Long userId =
                user.getId();

        UserStreakResponse streak =
                userActivityService.getStreak(user);

        int totalXp =
                userProgressRepository
                        .findByUserId(userId)
                        .map(UserProgress::getTotalXp)
                        .orElse(0);

        int currentLevel =
                resolveCurrentLevel(totalXp, userId);

        long completedCoursesCount =
                courseEnrollmentRepository
                        .countByUserIdAndStatusAndCourseOrganizationVisible(
                                userId,
                                EnrollmentStatus.COMPLETED
                        );

        long certificatesCount =
                certificateRepository.countByUserId(userId);

        long friendsCount =
                friendRepository.countByUserId(userId);

        long completedRoadmapsCount =
                roadmapFollowerRepository
                        .countByUserIdAndStatusAndRoadmapOrganizationVisible(
                                userId,
                                RoadmapFollowStatus.COMPLETED
                        );

        return eligibleCodes(
                streak.longestStreak(),
                completedCoursesCount,
                certificatesCount,
                friendsCount,
                completedRoadmapsCount,
                totalXp,
                currentLevel
        );
    }

    private int resolveCurrentLevel(
            int totalXp,
            Long userId
    ) {

        Level currentLevel =
                userProgressRepository
                        .findByUserId(userId)
                        .map(UserProgress::getCurrentLevel)
                        .orElse(null);

        if (currentLevel == null) {
            currentLevel =
                    levelRepository
                            .findTopByRequiredXpLessThanEqualOrderByRequiredXpDesc(
                                    totalXp
                            )
                            .orElse(null);
        }

        return currentLevel != null
                ? currentLevel.getLevelNumber()
                : 0;
    }

    private List<String> eligibleCodes(
            int longestStreak,
            long completedCoursesCount,
            long certificatesCount,
            long friendsCount,
            long completedRoadmapsCount,
            int totalXp,
            int currentLevel
    ) {

        Set<String> codes =
                new LinkedHashSet<>();

        if (longestStreak > 0) {
            codes.add(FIRST_STREAK);
        }

        if (longestStreak >= 7) {
            codes.add(WEEK_STREAK);
        }

        if (longestStreak >= 30) {
            codes.add(MONTH_STREAK);
        }

        if (completedCoursesCount > 0) {
            codes.add(COURSE_FINISHER);
        }

        if (completedCoursesCount >= 5) {
            codes.add(FIVE_COURSES);
        }

        if (certificatesCount > 0) {
            codes.add(CERTIFIED_LEARNER);
        }

        if (friendsCount > 0) {
            codes.add(CONNECTED_LEARNER);
        }

        if (friendsCount >= 10) {
            codes.add(SOCIAL_LEARNER);
        }

        if (completedRoadmapsCount > 0) {
            codes.add(ROADMAP_FINISHER);
        }

        if (totalXp >= 1000) {
            codes.add(XP_1000);
        }

        if (totalXp >= 5000) {
            codes.add(XP_5000);
        }

        if (currentLevel >= 5) {
            codes.add(LEVEL_5);
        }

        if (currentLevel >= 10) {
            codes.add(LEVEL_10);
        }

        if (currentLevel >= 20) {
            codes.add(LEVEL_20);
        }

        return new ArrayList<>(codes);
    }
}
