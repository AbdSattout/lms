package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class CreateInviteRequest {

    @NotNull
    private Long userId;

    private Role role;

}
