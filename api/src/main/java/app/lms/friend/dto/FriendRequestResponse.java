package app.lms.friend.dto;

import app.lms.friend.enums.FriendRequestStatus;
import app.lms.user.dto.UserResponse;

import java.time.Instant;

public record FriendRequestResponse(

        Long id,

        UserResponse sender,

        UserResponse receiver,

        FriendRequestStatus status,

        Instant createdAt

) {
}
