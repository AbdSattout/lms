package app.lms.friend.dto;

import app.lms.user.dto.UserResponse;

import java.time.Instant;

public record FriendResponse(

        Long id,

        UserResponse user,

        Instant createdAt

) {
}
