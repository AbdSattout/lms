package app.lms.organization.organizationJoinRequest.dto;

import app.lms.organization.organizationJoinRequest.enums.JoinRequestStatus;
import app.lms.user.dto.UserResponse;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class JoinRequestResponse {
    private Long id;
    private JoinRequestStatus status;
    private LocalDateTime createdAt;
    private UserResponse user;
}
