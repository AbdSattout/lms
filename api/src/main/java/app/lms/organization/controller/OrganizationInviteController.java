package app.lms.organization.controller;

import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/organizations/{slug}/invites")
@RequiredArgsConstructor
public class OrganizationInviteController {

    private final OrganizationMemberAccessService organizationMemberAccessService;

    @PostMapping("/accept")
    public ResponseEntity<Void> acceptInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationMemberAccessService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/decline")
    public ResponseEntity<Void> declineInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationMemberAccessService.decline(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/public/accept")
    public ResponseEntity<Void> acceptPublicInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationMemberAccessService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }
}
