package app.lms.dto;




public record AuthResponse(
        String token,
        UserResponse user
) {
}