package app.lms.user.service;

import app.lms.badge.service.UserBadgeService;
import app.lms.certificate.repository.CertificateRepository;
import app.lms.common.exception.NotFoundException;
import app.lms.course.dto.CourseResponse;
import app.lms.course.mapper.CourseMapper;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.friend.enums.FriendRequestStatus;
import app.lms.friend.enums.FriendshipStatus;
import app.lms.friend.model.Friend;
import app.lms.friend.model.FriendRequest;
import app.lms.friend.repository.FriendRepository;
import app.lms.friend.repository.FriendRequestRepository;
import app.lms.gamification.dto.UserStreakResponse;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.gamification.service.UserActivityService;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.roadmap.enums.RoadmapFollowStatus;
import app.lms.roadmap.repository.RoadmapFollowerRepository;
import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.PublicUserProfileResponse;
import app.lms.user.dto.UserProfileFriendshipResponse;
import app.lms.user.dto.UserProfileGamificationResponse;
import app.lms.user.dto.UserProfileStatsResponse;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.Profile;
import app.lms.user.model.User;
import app.lms.user.repository.ProfileRepository;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PublicUserProfileService {

    private static final int RECENT_COURSES_LIMIT = 5;

    private final UserRepository userRepository;
    private final ProfileRepository profileRepository;
    private final UserMapper userMapper;
    private final FriendRepository friendRepository;
    private final FriendRequestRepository friendRequestRepository;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final CourseEnrollmentRepository courseEnrollmentRepository;
    private final CourseMapper courseMapper;
    private final CertificateRepository certificateRepository;
    private final RoadmapFollowerRepository roadmapFollowerRepository;
    private final UserProgressRepository userProgressRepository;
    private final LevelRepository levelRepository;
    private final UserActivityService userActivityService;
    private final UserBadgeService userBadgeService;

    @Transactional
    public PublicUserProfileResponse getProfile(
            Long userId,
            User viewer
    ) {

        User user =
                userRepository
                        .findById(userId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "User not found"
                                )
                        );

        Profile profile =
                profileRepository
                        .findByUserId(user.getId())
                        .orElse(null);

        ProfileResponse profileResponse =
                userMapper.toProfileResponse(
                        user,
                        profile
                );

        UserProfileStatsResponse stats =
                statsFor(user);

        UserProfileGamificationResponse gamification =
                gamificationFor(user);

        return new PublicUserProfileResponse(
                profileResponse,
                friendshipFor(
                        viewer,
                        user
                ),
                stats,
                gamification,
                userBadgeService.syncAndListBadges(user),
                recentCoursesFor(user)
        );
    }

    private UserProfileFriendshipResponse friendshipFor(
            User viewer,
            User user
    ) {

        if (viewer.getId().equals(user.getId())) {
            return new UserProfileFriendshipResponse(
                    FriendshipStatus.SELF,
                    false,
                    null,
                    null
            );
        }

        Long user1 =
                Math.min(
                        viewer.getId(),
                        user.getId()
                );

        Long user2 =
                Math.max(
                        viewer.getId(),
                        user.getId()
                );

        if (friendRepository.existsByUser1IdAndUser2Id(
                user1,
                user2
        )) {
            Long friendId =
                    friendRepository
                            .findByUser1IdAndUser2Id(
                                    user1,
                                    user2
                            )
                            .map(Friend::getId)
                            .orElse(null);

            return new UserProfileFriendshipResponse(
                    FriendshipStatus.FRIENDS,
                    false,
                    null,
                    friendId
            );
        }

        FriendRequest pendingRequest =
                friendRequestRepository
                        .findBetweenUsersAndStatus(
                                viewer.getId(),
                                user.getId(),
                                FriendRequestStatus.PENDING
                        )
                        .orElse(null);

        if (pendingRequest == null) {
            return new UserProfileFriendshipResponse(
                    FriendshipStatus.NONE,
                    true,
                    null,
                    null
            );
        }

        FriendshipStatus status =
                pendingRequest
                        .getSender()
                        .getId()
                        .equals(viewer.getId())
                        ? FriendshipStatus.REQUEST_SENT
                        : FriendshipStatus.REQUEST_RECEIVED;

        return new UserProfileFriendshipResponse(
                status,
                false,
                pendingRequest.getId(),
                null
        );
    }

    private UserProfileStatsResponse statsFor(
            User user
    ) {

        Long userId =
                user.getId();

        return new UserProfileStatsResponse(
                friendRepository.countByUserId(userId),
                organizationMemberRepository.countVisibleByUserId(userId),
                courseEnrollmentRepository
                        .countByUserIdAndStatusAndCourseOrganizationVisible(
                                userId,
                                EnrollmentStatus.ACTIVE
                        ),
                courseEnrollmentRepository
                        .countByUserIdAndStatusAndCourseOrganizationVisible(
                                userId,
                                EnrollmentStatus.COMPLETED
                        ),
                roadmapFollowerRepository.countActiveByUserId(userId),
                roadmapFollowerRepository
                        .countByUserIdAndStatusAndRoadmapOrganizationVisible(
                                userId,
                                RoadmapFollowStatus.COMPLETED
                        ),
                certificateRepository.countByUserId(userId)
        );
    }

    private UserProfileGamificationResponse gamificationFor(
            User user
    ) {

        UserStreakResponse streak =
                userActivityService.getStreak(user);

        UserProgress progress =
                userProgressRepository
                        .findByUserId(user.getId())
                        .orElse(null);

        int totalXp =
                progress != null
                        ? progress.getTotalXp()
                        : 0;

        Level level =
                progress != null
                        ? progress.getCurrentLevel()
                        : null;

        if (level == null) {
            level =
                    levelRepository
                            .findTopByRequiredXpLessThanEqualOrderByRequiredXpDesc(
                                    totalXp
                            )
                            .orElse(null);
        }

        return new UserProfileGamificationResponse(
                totalXp,
                level != null
                        ? level.getLevelNumber()
                        : null,
                level != null
                        ? level.getTitle()
                        : null,
                level != null
                        ? level.getTier()
                        : null,
                streak
        );
    }

    private List<CourseResponse> recentCoursesFor(
            User user
    ) {

        return courseEnrollmentRepository
                .findProfileCoursesByUserId(
                        user.getId(),
                        List.of(
                                EnrollmentStatus.ACTIVE,
                                EnrollmentStatus.COMPLETED
                        ),
                        PageRequest.of(
                                0,
                                RECENT_COURSES_LIMIT
                        )
                )
                .getContent()
                .stream()
                .map(enrollment ->
                        courseMapper.toResponse(
                                enrollment.getCourse(),
                                enrollment
                        )
                )
                .toList();
    }

}
