package app.lms.friend.dto;

import app.lms.friend.enums.FriendRequestStatus;
import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record FriendRequestResponse(

        Long id,

        UserResponse sender,

        UserResponse receiver,

        FriendRequestStatus status,

        LocalDateTime createdAt

) {
}
