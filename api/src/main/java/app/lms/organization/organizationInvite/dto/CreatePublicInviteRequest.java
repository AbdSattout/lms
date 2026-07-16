package app.lms.organization.organizationInvite.dto;

import app.lms.organization.enums.Role;
import lombok.Data;

@Data
public class CreatePublicInviteRequest {
    private Role role;

    private Integer maxUses;
}