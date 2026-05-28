package app.lms.organization.controller;

import app.lms.security.UserPrincipal;
import app.lms.organization.dto.CreateOrganizationRequest;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.UpdateOrganizationRequest;
import app.lms.organization.service.OrganizationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
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

    @PostMapping
    public ResponseEntity<OrganizationResponse> create(

            @Valid
            @RequestBody CreateOrganizationRequest request,

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

    @GetMapping("/{name}")
    public ResponseEntity<OrganizationResponse> getByName(
            @PathVariable String name
    ) {

        return ResponseEntity.ok(
                organizationService.getByName(name)
        );
    }

    @GetMapping
    public ResponseEntity<List<OrganizationResponse>> getAll() {

        return ResponseEntity.ok(
                organizationService.getAll()
        );
    }

    @PatchMapping("/{name}")
    public ResponseEntity<OrganizationResponse> update(

            @PathVariable String name,

            @RequestBody UpdateOrganizationRequest request,

            @RequestPart(required = false)
            MultipartFile image,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationService.update(
                        name,
                        request,
                        image,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{name}")
    public ResponseEntity<?> delete(

            @PathVariable String name,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        organizationService.delete(
                name,
                principal.user()
        );

        return ResponseEntity.ok(
                "Organization deleted"
        );
    }
}
