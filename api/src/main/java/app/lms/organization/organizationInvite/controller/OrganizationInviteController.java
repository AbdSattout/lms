package app.lms.organization.organizationInvite.controller;

import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.service.OrganizationInviteService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class OrganizationInviteController {

    private final OrganizationInviteService organizationInviteService;

    @PostMapping("/organizations/{slug}/invites/{inviteId}/accept")
    public ResponseEntity<Void> acceptInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.acceptInvite(slug, inviteId, principal.user());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/organizations/{slug}/invites/{inviteId}/decline")
    public ResponseEntity<Void> declineInvite(
            @PathVariable String slug,
            @PathVariable Long inviteId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.decline(slug, inviteId, principal.user());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/organizations/invites/accept")
    public ResponseEntity<Void> acceptInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/organizations/invites/preview")
    public ResponseEntity<OrganizationInviteResponse> previewInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(
                organizationInviteService.previewInvite(token, principal.user())
        );
    }

    @PostMapping("/organizations/invites/decline")
    public ResponseEntity<Void> declineInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.decline(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/organizations/invites/public/accept")
    public ResponseEntity<Void> acceptPublicInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/organizations/invites/my-invites")
    public ResponseEntity<List<OrganizationInviteResponse>> getMyStudentInvites(
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(
                organizationInviteService.getMyInvites(principal.user(), Role.STUDENT)
        );
    }
}
