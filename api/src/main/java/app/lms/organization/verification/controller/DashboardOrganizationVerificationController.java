package app.lms.organization.verification.controller;

import app.lms.organization.verification.dto.OrganizationVerificationResponse;
import app.lms.organization.verification.dto.SubmitOrganizationVerificationRequest;
import app.lms.organization.verification.service.DashboardOrganizationVerificationService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@RequestMapping("/dashboard/organizations/{slug}/verification-requests")
public class DashboardOrganizationVerificationController {

    private final DashboardOrganizationVerificationService verificationService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<OrganizationVerificationResponse> submit(
            @PathVariable
            String slug,

            @RequestPart(required = false)
            @Valid
            SubmitOrganizationVerificationRequest request,

            @RequestPart("proof")
            MultipartFile proof,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        verificationService.submit(
                                slug,
                                request,
                                proof,
                                principal.user()
                        )
                );
    }

    @GetMapping
    public ResponseEntity<Page<OrganizationVerificationResponse>> list(
            @PathVariable
            String slug,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                verificationService.list(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }
}
