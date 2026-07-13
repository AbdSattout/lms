package app.lms.organization.controller;

import app.lms.organization.dto.CreateInviteRequest;
import app.lms.organization.dto.CreatePublicInviteRequest;
import app.lms.organization.dto.OrganizationInviteResponse;
import app.lms.organization.dto.UpdateInviteCapacityRequest;
import app.lms.organization.service.DashboardOrganizationService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/dashboard/organizations/{slug}/invites")
@RequiredArgsConstructor
public class DashboardOrganizationInviteController {

    private final DashboardOrganizationService dashboardOrganizationService;
    private final OrganizationMemberAccessService organizationMemberAccessService;

    @PostMapping
    public ResponseEntity<OrganizationInviteResponse> createInvite(
            @PathVariable String slug,
            @Valid @RequestBody CreateInviteRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(dashboardOrganizationService.invite(slug, request, principal.user()));
    }

    @PostMapping("/public")
    public ResponseEntity<OrganizationInviteResponse> createPublicInvite(
            @PathVariable String slug,
            @Valid @RequestBody CreatePublicInviteRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(dashboardOrganizationService.createPublicInvite(slug, request, principal.user()));
    }

    @GetMapping
    public ResponseEntity<List<OrganizationInviteResponse>> getPendingInvites(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(dashboardOrganizationService.getPendingInvites(slug, principal.user()));
    }

    @PostMapping("/{inviteId}/resend")
    public ResponseEntity<OrganizationInviteResponse> resendInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(dashboardOrganizationService.resendInvite(slug, inviteId, principal.user()));
    }

    @PostMapping("/{inviteId}/cancel")
    public ResponseEntity<Void> cancelInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationMemberAccessService.cancelInvite(slug, inviteId, principal.user());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{inviteId}/capacity")
    public ResponseEntity<OrganizationInviteResponse> updatePublicInviteCapacity(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @Valid @RequestBody UpdateInviteCapacityRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(dashboardOrganizationService.updatePublicInviteCapacity(slug, inviteId, request, principal.user()));
    }
}
