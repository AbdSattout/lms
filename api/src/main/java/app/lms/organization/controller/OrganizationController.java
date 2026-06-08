package app.lms.organization.controller;


import app.lms.organization.dto.OrganizationResponse;

import app.lms.organization.service.OrganizationService;

import lombok.RequiredArgsConstructor;


import org.springframework.http.ResponseEntity;

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



}
