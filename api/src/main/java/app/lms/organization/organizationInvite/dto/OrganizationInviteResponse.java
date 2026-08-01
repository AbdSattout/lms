package app.lms.organization.organizationInvite.dto;

import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.enums.Role;
import com.fasterxml.jackson.annotation.JsonInclude;
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
    private String token;
    private OrganizationInviteOrganizationResponse organization;
    @JsonInclude(JsonInclude.Include.NON_NULL)
    private OrganizationInviteOverviewResponse overview;
    private String invitedByName;
    private LocalDateTime expiresAt;
    private Integer maxUses;
    private int usedCount;
    private BaseEntityResponse baseEntity;
}
