package app.lms.organization.controller;

import app.lms.moderation.dto.BanRequest;
import app.lms.organization.dto.CreateOrganizationRequest;
import app.lms.organization.dto.OrganizationBannedUserResponse;
import app.lms.organization.dto.OrganizationMemberResponse;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.OrganizationUserSearchResponse;
import app.lms.organization.dto.UpdateOrganizationRequest;
import app.lms.organization.enums.Role;
import app.lms.organization.service.DashboardOrganizationService;
import app.lms.security.UserPrincipal;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/dashboard/organizations")
@RequiredArgsConstructor
public class DashboardOrganizationController {

    private final DashboardOrganizationService dashboardOrganizationService;


    @GetMapping
    public ResponseEntity<
            List<OrganizationResponse>
            > getAll(

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService
                        .getDashboardOrganizations(
                                principal.user()
                        )
        );
    }
    @PostMapping(
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<OrganizationResponse> create(

            @Valid
            @RequestPart CreateOrganizationRequest request,

            @RequestPart(required = false)
            MultipartFile image,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(
                        dashboardOrganizationService.create(
                                request,
                                image,
                                principal.user()
                        )
                );
    }

    @PatchMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> update(

            @PathVariable String slug,

            @Valid
            @RequestPart UpdateOrganizationRequest request,

            @RequestPart(required = false)
            MultipartFile image,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.update(
                        slug,
                        request,
                        image,
                        principal.user()
                )
        );
    }
    @DeleteMapping("/{slug}")
    public ResponseEntity<?> delete(

            @PathVariable String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        dashboardOrganizationService.delete(
                slug,
                principal.user()
        );

        return ResponseEntity.ok(
                "Organization deleted"
        );
    }

    @GetMapping("/check-availability")
    public ResponseEntity<Boolean> checkSlugAvailability(
            @RequestParam String slug
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.isSlugAvailable(slug)
        );
    }

    @GetMapping("/{slug}")
    public ResponseEntity<OrganizationResponse> getBySlug(

            @PathVariable
            String slug,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getDashboardOrganization(
                        slug,
                        principal.user()
                )
        );
    }
    @GetMapping("/{slug}/members")
    public ResponseEntity<Page<OrganizationMemberResponse>> getMembers(

            @PathVariable
            String slug,

            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getMembers(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }
    @GetMapping("/{slug}/members/owners")
    public ResponseEntity<Page<OrganizationMemberResponse>> getOwners(

            @PathVariable String slug,

            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getMembersByRole(
                        slug,
                        Role.OWNER,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/{slug}/members/admins")
    public ResponseEntity<Page<OrganizationMemberResponse>> getAdmins(

            @PathVariable String slug,

            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getMembersByRole(
                        slug,
                        Role.ADMIN,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/{slug}/members/students")
    public ResponseEntity<Page<OrganizationMemberResponse>> getStudents(

            @PathVariable String slug,

            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getMembersByRole(
                        slug,
                        Role.STUDENT,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/{slug}/users/banned")
    public ResponseEntity<Page<OrganizationBannedUserResponse>> getBannedUsers(

            @PathVariable
            String slug,

            @PageableDefault(size = 20)
            Pageable pageable,

            @AuthenticationPrincipal
            UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.getBannedUsers(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/{slug}/users/search")
    public ResponseEntity<List<OrganizationUserSearchResponse>> searchUsers(
            @PathVariable String slug,
            @RequestParam String q,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                dashboardOrganizationService.searchUsers(
                        slug,
                        q,
                        principal.user()
                )
        );
    }

    @DeleteMapping("/{slug}/members/{userId}")
    public ResponseEntity<Void> removeMember(
            @PathVariable String slug,
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        dashboardOrganizationService.removeMember(
                slug,
                userId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/{slug}/users/{userId}/ban")
    public ResponseEntity<Void> banUser(
            @PathVariable String slug,
            @PathVariable Long userId,
            @RequestBody
            @Valid
            BanRequest request,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        dashboardOrganizationService.banUser(
                slug,
                userId,
                request,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/{slug}/users/{userId}/ban")
    public ResponseEntity<Void> unbanUser(
            @PathVariable String slug,
            @PathVariable Long userId,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        dashboardOrganizationService.unbanUser(
                slug,
                userId,
                principal.user()
        );

        return ResponseEntity.noContent().build();
    }
}
