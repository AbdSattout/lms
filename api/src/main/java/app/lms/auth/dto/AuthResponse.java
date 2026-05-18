package app.lms.auth.dto;


import app.lms.user.dto.UserResponse;

public record AuthResponse(
        String token,
        UserResponse user
) {
}