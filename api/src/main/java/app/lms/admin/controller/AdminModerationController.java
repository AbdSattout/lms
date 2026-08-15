package app.lms.admin.controller;

import app.lms.admin.dto.BannedOrganizationResponse;
import app.lms.admin.dto.BannedUserResponse;
import app.lms.admin.security.AdminPrincipal;
import app.lms.admin.service.AdminModerationService;
import app.lms.moderation.dto.BanRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/moderation")
public class AdminModerationController {

    private final AdminModerationService moderationService;

    @GetMapping("/users/banned")
    public ResponseEntity<Page<BannedUserResponse>> getBannedUsers(

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                moderationService.getBannedUsers(
                        admin.getId(),
                        pageable
                )
        );
    }


    @PostMapping("/users/{userId}/ban")
    public ResponseEntity<Void> banUser(

            @PathVariable
            Long userId,

            @RequestBody
            @Valid
            BanRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.banUser(
                userId,
                request,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
    }

    @DeleteMapping("/users/{userId}/ban")
    public ResponseEntity<Void> unbanUser(

            @PathVariable
            Long userId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.unbanUser(
                userId,
                admin.getId()
        );

        return ResponseEntity.noContent()
                .build();
    }

    @GetMapping("/organizations/banned")
    public ResponseEntity<Page<BannedOrganizationResponse>> getBannedOrganizations(

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                moderationService.getBannedOrganizations(
                        admin.getId(),
                        pageable
                )
        );
    }

    @PostMapping("/organizations/{organizationId}/ban")
    public ResponseEntity<Void> banOrganization(

            @PathVariable
            Long organizationId,

            @RequestBody
            @Valid
            BanRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.banOrganization(
                organizationId,
                request,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
    }

    @DeleteMapping("/organizations/{organizationId}/ban")
    public ResponseEntity<Void> unbanOrganization(

            @PathVariable
            Long organizationId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.unbanOrganization(
                organizationId,
                admin.getId()
        );

        return ResponseEntity.noContent()
                .build();
    }


}
