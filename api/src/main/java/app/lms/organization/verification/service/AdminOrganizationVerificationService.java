package app.lms.organization.verification.service;

import app.lms.admin.model.Admin;
import app.lms.admin.service.AdminModerationAccessService;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.organization.verification.dto.OrganizationVerificationResponse;
import app.lms.organization.verification.dto.ReviewOrganizationVerificationRequest;
import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import app.lms.organization.verification.mapper.OrganizationVerificationMapper;
import app.lms.organization.verification.model.OrganizationVerificationRequest;
import app.lms.organization.verification.repository.OrganizationVerificationRequestRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AdminOrganizationVerificationService {

    private final OrganizationVerificationRequestRepository requestRepository;
    private final OrganizationVerificationMapper verificationMapper;
    private final AdminModerationAccessService accessService;

    @Transactional
    public Page<OrganizationVerificationResponse> list(
            Long adminId,
            OrganizationVerificationStatus status,
            Pageable pageable
    ) {

        validateAdmin(adminId);

        Page<OrganizationVerificationRequest> requests =
                status != null
                        ? requestRepository
                                .findAllByStatusOrderByCreatedAtDesc(
                                        status,
                                        pageable
                                )
                        : requestRepository
                                .findAllByOrderByCreatedAtDesc(
                                        pageable
                                );

        return requests.map(
                verificationMapper::toResponse
        );
    }

    @Transactional
    public OrganizationVerificationResponse getById(
            Long adminId,
            Long requestId
    ) {

        validateAdmin(adminId);

        return verificationMapper.toResponse(
                getRequest(requestId)
        );
    }

    @Transactional
    public OrganizationVerificationResponse review(
            Long adminId,
            Long requestId,
            ReviewOrganizationVerificationRequest request
    ) {

        Admin admin =
                validateAdmin(adminId);

        validateReviewStatus(
                request.status()
        );

        OrganizationVerificationRequest verificationRequest =
                getRequest(requestId);

        validatePending(
                verificationRequest
        );

        verificationRequest.setStatus(
                request.status()
        );

        verificationRequest.setReviewedBy(
                admin
        );

        verificationRequest.setAdminNote(
                request.adminNote()
        );

        verificationRequest.setReviewedAt(
                LocalDateTime.now()
        );

        if (request.status()
                == OrganizationVerificationStatus.APPROVED) {
            verificationRequest.getOrganization()
                    .setVerified(true);
        }

        return verificationMapper.toResponse(
                verificationRequest
        );
    }

    private Admin validateAdmin(
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateAdmin(
                admin
        );

        return admin;
    }

    private OrganizationVerificationRequest getRequest(
            Long requestId
    ) {

        return requestRepository
                .findByIdWithDetails(
                        requestId
                )
                .orElseThrow(() ->
                        new NotFoundException(
                                "Organization verification request not found"
                        )
                );
    }

    private void validateReviewStatus(
            OrganizationVerificationStatus status
    ) {

        if (status == OrganizationVerificationStatus.PENDING) {
            throw new BadRequestException(
                    "Review status must be APPROVED or REJECTED"
            );
        }
    }

    private void validatePending(
            OrganizationVerificationRequest request
    ) {

        if (request.getStatus()
                != OrganizationVerificationStatus.PENDING) {
            throw new ConflictException(
                    "Organization verification request already reviewed"
            );
        }
    }
}
