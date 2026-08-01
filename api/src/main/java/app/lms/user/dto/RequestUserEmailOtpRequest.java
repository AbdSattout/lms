package app.lms.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class RequestUserEmailOtpRequest {

    @NotBlank
    @Email
    private String email;
}
