package app.lms.organization.controller;


import app.lms.organization.dto.OrganizationResponse;

import app.lms.organization.service.OrganizationService;

import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;


import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;


import java.util.List;

@RestController
@RequestMapping("/organizations")
@RequiredArgsConstructor
public class OrganizationController {

    private final OrganizationService organizationService;


    @GetMapping
    public ResponseEntity<Page<OrganizationResponse>> getAll(
            @RequestParam(required = false)
            String q,

            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationService.getAll(
                        q,
                        principal.user(),
                        pageable
                )
        );
    }

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> getBySlug(
            @PathVariable String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationService.getBySlug(
                        slug,
                        principal.user()
                )
        );
    }

    @GetMapping("/me")
    public ResponseEntity<List<OrganizationResponse>> myOrganizations(

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationService.getMyOrganizations(
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{slug}/leave")
    public ResponseEntity<Void> leaveOrganization(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        organizationService.leaveOrganization(
                slug,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }




}
