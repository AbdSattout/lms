package app.lms.organization.verification.controller;

import app.lms.admin.security.AdminPrincipal;
import app.lms.organization.verification.dto.OrganizationVerificationResponse;
import app.lms.organization.verification.dto.ReviewOrganizationVerificationRequest;
import app.lms.organization.verification.enums.OrganizationVerificationStatus;
import app.lms.organization.verification.service.AdminOrganizationVerificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/organization-verifications")
public class AdminOrganizationVerificationController {

    private final AdminOrganizationVerificationService verificationService;

    @GetMapping
    public ResponseEntity<Page<OrganizationVerificationResponse>> list(
            @RequestParam(required = false)
            OrganizationVerificationStatus status,

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin
    ) {

        return ResponseEntity.ok(
                verificationService.list(
                        admin.getId(),
                        status,
                        pageable
                )
        );
    }

    @GetMapping("/{requestId}")
    public ResponseEntity<OrganizationVerificationResponse> getById(
            @PathVariable
            Long requestId,

            @AuthenticationPrincipal
            AdminPrincipal admin
    ) {

        return ResponseEntity.ok(
                verificationService.getById(
                        admin.getId(),
                        requestId
                )
        );
    }

    @PatchMapping("/{requestId}")
    public ResponseEntity<OrganizationVerificationResponse> review(
            @PathVariable
            Long requestId,

            @RequestBody
            @Valid
            ReviewOrganizationVerificationRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin
    ) {

        return ResponseEntity.ok(
                verificationService.review(
                        admin.getId(),
                        requestId,
                        request
                )
        );
    }
}
