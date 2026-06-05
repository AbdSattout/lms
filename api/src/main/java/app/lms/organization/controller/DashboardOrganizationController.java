package app.lms.organization.controller;

import app.lms.organization.dto.CreateOrganizationRequest;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.UpdateOrganizationRequest;
import app.lms.organization.service.DashboardOrganizationService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/dashboard/organizations")
@RequiredArgsConstructor
public class DashboardOrganizationController {

    private final DashboardOrganizationService dashboardOrganizationService;


    @GetMapping
    public ResponseEntity<
            List<OrganizationResponse>
            > getAll(

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService
                        .getDashboardOrganizations(
                                principal.user()
                        )
        );
    }
    @PostMapping(
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<OrganizationResponse> create(

            @Valid
            @RequestPart CreateOrganizationRequest request,

            @RequestPart(required = false)
            MultipartFile image,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        dashboardOrganizationService.create(
                                request,
                                image,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> update(

            @PathVariable String slug,

            @Valid
            @RequestPart UpdateOrganizationRequest request,

            @RequestPart(required = false)
            MultipartFile image,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.update(
                        slug,
                        request,
                        image,
                        principal.user()
                )
        );
    }
    @DeleteMapping("/{slug}")
    public ResponseEntity<?> delete(

            @PathVariable String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        dashboardOrganizationService.delete(
                slug,
                principal.user()
        );

        return ResponseEntity.ok(
                "Organization deleted"
        );
    }

    @GetMapping("/check-availability")
    public ResponseEntity<Boolean> checkSlugAvailability(
            @RequestParam String slug
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.isSlugAvailable(slug)
        );
    }

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> getBySlug(

            @PathVariable
            String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getDashboardOrganization(
                        slug,
                        principal.user()
                )
        );
    }
}