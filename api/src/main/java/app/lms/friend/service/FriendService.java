package app.lms.friend.service;

import app.lms.badge.dto.UserBadgeResponse;
import app.lms.badge.service.UserBadgeService;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.NotFoundException;
import app.lms.friend.dto.FriendActionResponse;
import app.lms.friend.dto.FriendRequestResponse;
import app.lms.friend.dto.FriendResponse;
import app.lms.friend.enums.FriendRequestStatus;
import app.lms.friend.mapper.FriendMapper;
import app.lms.friend.model.Friend;
import app.lms.friend.model.FriendRequest;
import app.lms.friend.repository.FriendRepository;
import app.lms.friend.repository.FriendRequestRepository;
import app.lms.notification.enums.NotificationType;
import app.lms.notification.service.NotificationService;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.service.UserService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class FriendService {

    private final FriendRepository friendRepository;
    private final FriendRequestRepository friendRequestRepository;

    private final UserService userService;
    private final FriendMapper friendMapper;
    private final UserMapper userMapper;

    private final NotificationService notificationService;
    private final UserBadgeService userBadgeService;

    public void sendRequest(
            Long receiverId,
            User sender
    ) {

        if (sender.getId().equals(receiverId))
            throw new BadRequestException("you can not send for your self");

        User receiver =
                userService.findUserById(receiverId);

        Long user1 =
                Math.min(sender.getId(), receiver.getId());

        Long user2 =
                Math.max(sender.getId(), receiver.getId());

        if (friendRepository.existsByUser1IdAndUser2Id(user1, user2))
            throw new BadRequestException("this already your friend");

        if (friendRequestRepository.existsBetweenUsersAndStatus(
                sender.getId(),
                receiver.getId(),
                FriendRequestStatus.PENDING
        ))
            throw new BadRequestException("friend request already exists");

        FriendRequest request =
                FriendRequest.builder()
                        .sender(sender)
                        .receiver(receiver)
                        .status(FriendRequestStatus.PENDING)
                        .build();

        friendRequestRepository.save(request);

        notificationService.create(
                receiver,
                NotificationType.FRIEND_REQUEST,
                "New Friend Request",
                sender.getName() + " sent you a friend request.",
                "FRIEND_REQUEST",
                request.getId()
        );
    }

    public FriendActionResponse accept(
            Long requestId,
            User receiver
    ) {

        FriendRequest request =
                friendRequestRepository.findById(requestId)
                        .orElseThrow(()-> new NotFoundException("friend request not found"));

        if (!request.getReceiver().getId().equals(receiver.getId()))
            throw new BadRequestException("access denied");

        request.setStatus(FriendRequestStatus.ACCEPTED);
        request.setRespondedAt(LocalDateTime.now());

        User first =
                request.getSender().getId() < request.getReceiver().getId()
                        ? request.getSender()
                        : request.getReceiver();

        User second =
                request.getSender().getId() < request.getReceiver().getId()
                        ? request.getReceiver()
                        : request.getSender();

        friendRepository.save(
                Friend.builder()
                        .user1(first)
                        .user2(second)
                        .build()
        );

        friendRequestRepository.delete(request);

        notificationService.create(
                request.getSender(),
                NotificationType.FRIEND_REQUEST_ACCEPTED,
                "Friend Request Accepted",
                receiver.getName() + " accepted your friend request.",
                "USER",
                request.getSender().getId()
        );

        List<UserBadgeResponse> badges =
                userBadgeService.awardEarnedBadges(receiver);

        userBadgeService.awardEarnedBadges(
                request.getSender()
        );

        return new FriendActionResponse(
                badges
        );
    }

    public void reject(
            Long id,
            User receiver
    ) {

        FriendRequest request =
                friendRequestRepository.findById(id)
                        .orElseThrow(()-> new NotFoundException("friend request not found"));

        if (!request.getReceiver().getId().equals(receiver.getId()))
            throw new BadRequestException("access denied");

        request.setStatus(FriendRequestStatus.REJECTED);
        request.setRespondedAt(LocalDateTime.now());
    }

    public void cancel(
            Long id,
            User sender
    ) {

        FriendRequest request =
                friendRequestRepository.findById(id)
                        .orElseThrow(()-> new NotFoundException("friend request not found"));

        if (!request.getSender().getId().equals(sender.getId()))
            throw new BadRequestException("access denied");

        request.setStatus(FriendRequestStatus.CANCELED);
    }

    public void removeFriend(
            Long friendId,
            User user
    ) {

        Friend friend =
                friendRepository.findById(friendId)
                        .orElseThrow(()-> new NotFoundException("friend request not found"));

        if (!friend.getUser1().getId().equals(user.getId())
                && !friend.getUser2().getId().equals(user.getId()))
            throw new BadRequestException("access denied");

        friendRepository.delete(friend);
    }

    @Transactional()
    public Page<FriendRequestResponse> getReceivedRequests(
            User user,
            Pageable pageable
    ) {

        return friendRequestRepository
                .findAllByReceiverIdAndStatus(
                        user.getId(),
                        FriendRequestStatus.PENDING,
                        pageable
                )
                .map(friendMapper::toResponse);
    }

    @Transactional()
    public Page<FriendRequestResponse> getSentRequests(
            User user,
            Pageable pageable
    ) {

        return friendRequestRepository
                .findAllBySenderIdAndStatus(
                        user.getId(),
                        FriendRequestStatus.PENDING,
                        pageable
                )
                .map(friendMapper::toResponse);
    }

    @Transactional()
    public Page<FriendResponse> getFriends(
            User user,
            Pageable pageable
    ) {

        return friendRepository
                .findAllByUserId(
                        user.getId(),
                        pageable
                )
                .map(friend -> {

                    User friendUser =
                            friend.getUser1().getId().equals(user.getId())
                                    ? friend.getUser2()
                                    : friend.getUser1();

                    return new FriendResponse(
                            friend.getId(),
                            userMapper.toResponse(friendUser),
                            friend.getCreatedAt()
                    );
                });
    }

    public void validateIsFriends(
            Long user1Id,
            Long user2Id
    ) {

        boolean isFriend =
                friendRepository.existsByUser1IdAndUser2Id(
                        user1Id,
                        user2Id
                );

        if (!isFriend) {
            throw new ChatAccessDeniedException(
                    "You can only send messages to friends"
            );
        }
    }

}
