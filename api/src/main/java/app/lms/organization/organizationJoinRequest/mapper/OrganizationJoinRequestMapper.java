package app.lms.organization.organizationJoinRequest.mapper;

import app.lms.organization.organizationJoinRequest.dto.JoinRequestResponse;
import app.lms.organization.organizationJoinRequest.model.OrganizationJoinRequest;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrganizationJoinRequestMapper {

    private final UserMapper userMapper;

    public JoinRequestResponse toJoinRequestResponse(OrganizationJoinRequest request) {
        return JoinRequestResponse.builder()
                .id(request.getId())
                .status(request.getStatus())
                .createdAt(request.getCreatedAt())
                .user(userMapper.toResponse(request.getUser()))
                .build();
    }

}
