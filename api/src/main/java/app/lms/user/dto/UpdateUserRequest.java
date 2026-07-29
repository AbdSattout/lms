package app.lms.user.dto;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class UpdateUserRequest {

    private String name;

    @Size(
            min = 3,
            max = 30
    )
    @Pattern(
            regexp = "^[a-z0-9_]+$",
            message = "Username can only contain lowercase letters, numbers, and underscores"
    )
    private String username;
}
