package app.lms.organization.dto;

import app.lms.organization.enums.Role;
import app.lms.user.dto.UserResponse;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class OrganizationMemberResponse {

    private Long memberId;

    private UserResponse user;

    private Role role;

}
