package app.lms.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.Data;

@Data
public class LoginRequest {

    @NotEmpty
    String idToken;
}
