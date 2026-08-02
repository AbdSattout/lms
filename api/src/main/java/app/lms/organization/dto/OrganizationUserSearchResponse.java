package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.user.dto.UserResponse;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class OrganizationUserSearchResponse {

    private String name;

    private String email;

    private String phone;

    private String university;

    private UserResponse user;

    private boolean member;

    private Role role;

    private boolean invited;

    private Long inviteId;

    private InviteStatus inviteStatus;

    private Role inviteRole;
}
