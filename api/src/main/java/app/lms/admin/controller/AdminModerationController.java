package app.lms.admin.controller;

import app.lms.admin.dto.BanRequest;
import app.lms.admin.security.AdminPrincipal;
import app.lms.admin.service.AdminModerationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/moderation")
public class AdminModerationController {

    private final AdminModerationService moderationService;


    @PostMapping("/organizations/{organizationId}/users/{userId}/ban")
    public ResponseEntity<Void> banFromOrganization(

            @PathVariable
            Long organizationId,

            @PathVariable
            Long userId,

            @RequestBody
            @Valid
            BanRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.banFromOrganization(
                organizationId,
                userId,
                request,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
    }

    @DeleteMapping("/organizations/{organizationId}/users/{userId}/ban")
    public ResponseEntity<Void> unbanFromOrganization(

            @PathVariable
            Long organizationId,

            @PathVariable
            Long userId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.unbanFromOrganization(
                organizationId,
                userId,
                admin.getId()
        );

        return ResponseEntity.noContent()
                .build();
    }


    @PostMapping("/courses/{courseId}/users/{userId}/ban")
    public ResponseEntity<Void> banFromCourse(

            @PathVariable
            Long courseId,

            @PathVariable
            Long userId,

            @RequestBody
            @Valid
            BanRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.banFromCourse(
                courseId,
                userId,
                request,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
    }

    @DeleteMapping("/courses/{courseId}/users/{userId}/ban")
    public ResponseEntity<Void> unbanFromCourse(

            @PathVariable
            Long courseId,

            @PathVariable
            Long userId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.unbanFromCourse(
                courseId,
                userId,
                admin.getId()
        );

        return ResponseEntity.noContent()
                .build();
    }

    @PostMapping("/courses/{courseId}/ban")
    public ResponseEntity<Void> banCourse(

            @PathVariable
            Long courseId,

            @RequestBody
            @Valid
            BanRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.banCourse(
                courseId,
                request,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
    }

    @PostMapping("/courses/{courseId}/ban")
    public ResponseEntity<Void> unbanCourse(

            @PathVariable
            Long courseId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        moderationService.unbanCourse(
                courseId,
                admin.getId()
        );

        return ResponseEntity.ok()
                .build();
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

    @PostMapping("/organizations/{organizationId}/ban")
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

        return ResponseEntity.ok()
                .build();
    }


}
