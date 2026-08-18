package app.lms.organization.verification.mapper;

import app.lms.admin.mapper.AdminMapper;
import app.lms.common.dto.BaseEntityResponse;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.verification.dto.OrganizationVerificationResponse;
import app.lms.organization.verification.model.OrganizationVerificationRequest;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class OrganizationVerificationMapper {

    private final OrganizationMapper organizationMapper;
    private final UserMapper userMapper;
    private final AdminMapper adminMapper;

    public OrganizationVerificationResponse toResponse(
            OrganizationVerificationRequest request
    ) {

        return new OrganizationVerificationResponse(
                request.getId(),
                organizationMapper.ToResponse(
                        request.getOrganization()
                ),
                userMapper.toResponse(
                        request.getRequestedBy()
                ),
                request.getNote(),
                request.getProofUrl(),
                request.getStatus(),
                request.getReviewedBy() != null
                        ? adminMapper.toResponse(
                                request.getReviewedBy()
                        )
                        : null,
                request.getAdminNote(),
                request.getReviewedAt(),
                BaseEntityResponse.from(request)
        );
    }
}
