package app.lms.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class EmailOtpRequest {

    @NotBlank
    @Email
    private String email;
}
