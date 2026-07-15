package app.lms.organization.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.enums.InviteStatus;
import app.lms.organization.enums.Role;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;


@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class OrganizationInviteResponse {

    private Long id;
    private Long userId;
    private String userName;
    private Role role;
    private InviteStatus status;
    private String invitedByName;
    private LocalDateTime expiresAt;
    private LocalDateTime createdAt;
    private Integer maxUses;
    private int usedCount;
    private BaseEntityResponse baseEntity;
}
