package app.lms.organization.organizationInvite.controller;

import app.lms.organization.organizationInvite.dto.CreateInviteRequest;
import app.lms.organization.organizationInvite.dto.CreatePublicInviteRequest;
import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.organizationInvite.dto.UpdateInviteCapacityRequest;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.service.OrganizationInviteService;
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
@RequestMapping("/dashboard/organizations")
@RequiredArgsConstructor
public class DashboardOrganizationInviteController {

    private final OrganizationInviteService organizationInviteService;

    @PostMapping("/{slug}/invites")
    public ResponseEntity<OrganizationInviteResponse> createInvite(
            @PathVariable String slug,
            @Valid @RequestBody CreateInviteRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(organizationInviteService.invite(slug, request, principal.user()));
    }

    @PostMapping("/{slug}/invites/public")
    public ResponseEntity<OrganizationInviteResponse> createPublicInvite(
            @PathVariable String slug,
            @Valid @RequestBody CreatePublicInviteRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(organizationInviteService.createPublicInvite(slug, request, principal.user()));
    }

    @GetMapping("/{slug}/invites")
    public ResponseEntity<List<OrganizationInviteResponse>> getPendingInvites(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(organizationInviteService.getPendingInvites(slug, principal.user()));
    }
    @GetMapping("/invites/my-invites")
    public ResponseEntity<List<OrganizationInviteResponse>> getMyAdminInvites(
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(
                organizationInviteService.getMyInvites(principal.user(), Role.ADMIN)
        );
    }

    @PostMapping("/{slug}/invites/{inviteId}/resend")
    public ResponseEntity<OrganizationInviteResponse> resendInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(organizationInviteService.resendInvite(slug, inviteId, principal.user()));
    }

    @PostMapping("/{slug}/invites/{inviteId}/cancel")
    public ResponseEntity<Void> cancelInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.cancelInvite(slug, inviteId, principal.user());
        return ResponseEntity.ok().build();
    }

    @PatchMapping("/{slug}/invites/{inviteId}/capacity")
    public ResponseEntity<OrganizationInviteResponse> updatePublicInviteCapacity(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @Valid @RequestBody UpdateInviteCapacityRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(organizationInviteService.updatePublicInviteCapacity(slug, inviteId, request, principal.user()));
    }
}
