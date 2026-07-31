package app.lms.friend.dto;

import app.lms.user.dto.UserResponse;

import java.time.LocalDateTime;

public record FriendResponse(

        Long id,

        UserResponse user,

        LocalDateTime createdAt

) {
}
