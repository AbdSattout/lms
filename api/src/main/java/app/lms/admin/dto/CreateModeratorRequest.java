package app.lms.admin.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;

public record CreateModeratorRequest(
        @NotBlank
        String name,

        @NotBlank
        @Email
        String email,

        @NotBlank
        String password
) {
}
