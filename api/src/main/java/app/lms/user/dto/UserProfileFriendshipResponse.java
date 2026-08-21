package app.lms.user.dto;

import app.lms.friend.enums.FriendshipStatus;

public record UserProfileFriendshipResponse(
        FriendshipStatus status,
        boolean canSendFriendRequest,
        Long pendingRequestId,
        Long friendId
) {
}
