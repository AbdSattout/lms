package app.lms.friend.dto;

import app.lms.badge.dto.UserBadgeResponse;

import java.util.List;

public record FriendActionResponse(
        List<UserBadgeResponse> badges
) {
}
