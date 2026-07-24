package app.lms.organization.organizationInvite.controller;

import app.lms.organization.organizationInvite.dto.OrganizationInviteResponse;
import app.lms.organization.enums.Role;
import app.lms.organization.organizationInvite.service.OrganizationInviteService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/organizations/invites")
@RequiredArgsConstructor
public class OrganizationInviteController {

    private final OrganizationInviteService organizationInviteService;

    @PostMapping("/accept")
    public ResponseEntity<Void> acceptInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/decline")
    public ResponseEntity<Void> declineInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.decline(token, principal.user());
        return ResponseEntity.ok().build();
    }

    @GetMapping("/public/accept")
    public ResponseEntity<Void> acceptPublicInvite(
            @RequestParam String token,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        organizationInviteService.acceptInvite(token, principal.user());
        return ResponseEntity.ok().build();
    }
    @GetMapping("/my-invites")
    public ResponseEntity<List<OrganizationInviteResponse>> getMyStudentInvites(
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(
                organizationInviteService.getMyInvites(principal.user(), Role.STUDENT)
        );
    }
}
