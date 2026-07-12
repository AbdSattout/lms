package app.lms.organization.controller;


import app.lms.organization.dto.OrganizationResponse;

import app.lms.organization.service.OrganizationService;

import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;


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
    public ResponseEntity<List<OrganizationResponse>> getAll() {

        return ResponseEntity.ok(
                organizationService.getAll()
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



}
