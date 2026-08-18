package app.lms.organization.verification.service;

import app.lms.common.exception.ConflictException;
import app.lms.common.exception.ForbiddenException;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.service.MediaService;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.organization.verification.dto.OrganizationVerificationResponse;
import app.lms.organization.verification.dto.SubmitOrganizationVerificationRequest;
import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import app.lms.organization.verification.mapper.OrganizationVerificationMapper;
import app.lms.organization.verification.model.OrganizationVerificationRequest;
import app.lms.organization.verification.repository.OrganizationVerificationRequestRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class DashboardOrganizationVerificationService {

    private final OrganizationAccessService organizationAccessService;
    private final OrganizationVerificationRequestRepository requestRepository;
    private final OrganizationVerificationMapper verificationMapper;
    private final MediaService mediaService;

    @Transactional
    public OrganizationVerificationResponse submit(
            String organizationSlug,
            SubmitOrganizationVerificationRequest request,
            MultipartFile proof,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(
                        organizationSlug
                );

        validateOwner(
                organization,
                user
        );

        validateCanSubmit(
                organization
        );

        UploadedFile uploadedProof =
                mediaService.upload(
                        proof,
                        "/organizations/verification",
                        FileType.FILE
                );

        OrganizationVerificationRequest verificationRequest =
                OrganizationVerificationRequest.builder()
                        .organization(organization)
                        .requestedBy(user)
                        .note(
                                request != null &&
                                        request.note() != null
                                        ? request.note().trim()
                                        : null
                        )
                        .proofUrl(uploadedProof.url())
                        .proofFileId(uploadedProof.fileId())
                        .status(OrganizationVerificationStatus.PENDING)
                        .build();

        requestRepository.save(
                verificationRequest
        );

        return verificationMapper.toResponse(
                verificationRequest
        );
    }

    @Transactional
    public Page<OrganizationVerificationResponse> list(
            String organizationSlug,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService.getBySlug(
                        organizationSlug
                );

        validateOwner(
                organization,
                user
        );

        return requestRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(verificationMapper::toResponse);
    }

    private void validateOwner(
            Organization organization,
            User user
    ) {

        if (!organization.getOwner()
                .getId()
                .equals(user.getId())) {
            throw new ForbiddenException(
                    "Only organization owner can request verification"
            );
        }
    }

    private void validateCanSubmit(
            Organization organization
    ) {

        if (Boolean.TRUE.equals(
                organization.getVerified()
        )) {
            throw new ConflictException(
                    "Organization is already verified"
            );
        }

        boolean hasPendingRequest =
                requestRepository.existsByOrganizationIdAndStatus(
                        organization.getId(),
                        OrganizationVerificationStatus.PENDING
                );

        if (hasPendingRequest) {
            throw new ConflictException(
                    "Organization already has a pending verification request"
            );
        }
    }
}
