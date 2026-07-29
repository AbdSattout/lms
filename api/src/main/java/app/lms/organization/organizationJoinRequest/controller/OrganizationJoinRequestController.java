package app.lms.organization.organizationJoinRequest.controller;

import app.lms.organization.organizationJoinRequest.dto.JoinRequestResponse;
import app.lms.organization.organizationJoinRequest.service.OrganizationJoinRequestService;
import app.lms.security.UserPrincipal;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
public class OrganizationJoinRequestController {

    private final OrganizationJoinRequestService joinRequestService;


    @PostMapping("/organizations/{slug}/join-request")
    public ResponseEntity<JoinRequestResponse> createJoinRequest(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(joinRequestService.createRequest(slug, principal.user() ));
    }


    @DeleteMapping("/organizations/{slug}/join-request")
    public ResponseEntity<Void> cancelJoinRequest(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        joinRequestService.cancelRequest(slug, principal.user());
        return ResponseEntity.noContent().build();
    }


    @GetMapping("/dashboard/organizations/{slug}/join-requests")
    public ResponseEntity<List<JoinRequestResponse>> getPendingRequests(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        return ResponseEntity.ok(joinRequestService.getPendingRequests(slug, principal.user()));
    }


    @PostMapping("/dashboard/organizations/{slug}/join-requests/{id}/accept")
    public ResponseEntity<Void> acceptRequest(
            @PathVariable String slug,
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        joinRequestService.acceptRequest(slug, id, principal.user());
        return ResponseEntity.ok().build();
    }


    @PostMapping("/dashboard/organizations/{slug}/join-requests/{id}/reject")
    public ResponseEntity<Void> rejectRequest(
            @PathVariable String slug,
            @PathVariable Long id,
            @AuthenticationPrincipal UserPrincipal principal
    ) {
        joinRequestService.rejectRequest(slug, id, principal.user());
        return ResponseEntity.ok().build();
    }
}
