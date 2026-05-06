package app.lms.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

@Data
public class LoginRequest {

    @NotBlank @NotEmpty
    String idToken;
}
