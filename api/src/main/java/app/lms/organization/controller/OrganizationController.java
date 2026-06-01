package app.lms.organization.controller;

import app.lms.security.UserPrincipal;
import app.lms.organization.dto.CreateOrganizationRequest;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.UpdateOrganizationRequest;
import app.lms.organization.service.OrganizationService;
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
@RequestMapping("/organizations")
@RequiredArgsConstructor
public class OrganizationController {

    private final OrganizationService organizationService;

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
                        organizationService.create(
                                request,
                                image,
                                principal.user()
                        )
                );
    }

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> getBySlug(
            @PathVariable String slug
    ) {

        return ResponseEntity.ok(
                organizationService.getBySlug(slug)
        );
    }

    @GetMapping
    public ResponseEntity<List<OrganizationResponse>> getAll() {

        return ResponseEntity.ok(
                organizationService.getAll()
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
                organizationService.update(
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

        organizationService.delete(
                slug,
                principal.user()
        );

        return ResponseEntity.ok(
                "Organization deleted"
        );
    }
}
