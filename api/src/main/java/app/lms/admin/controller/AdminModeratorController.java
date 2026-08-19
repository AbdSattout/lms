package app.lms.admin.controller;

import app.lms.admin.dto.AdminResponse;
import app.lms.admin.dto.CreateModeratorRequest;
import app.lms.admin.security.AdminPrincipal;
import app.lms.admin.service.AdminModeratorService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/moderators")
public class AdminModeratorController {

    private final AdminModeratorService adminModeratorService;

    @GetMapping
    public ResponseEntity<Page<AdminResponse>> listModerators(

            Pageable pageable,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity.ok(
                adminModeratorService.listModerators(
                        admin.getId(),
                        pageable
                )
        );
    }

    @PostMapping
    public ResponseEntity<AdminResponse> createModerator(

            @RequestBody
            @Valid
            CreateModeratorRequest request,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(
                        adminModeratorService.createModerator(
                                admin.getId(),
                                request
                        )
                );
    }

    @DeleteMapping("/{moderatorId}")
    public ResponseEntity<Void> deleteModerator(

            @PathVariable
            Long moderatorId,

            @AuthenticationPrincipal
            AdminPrincipal admin

    ) {

        adminModeratorService.deleteModerator(
                admin.getId(),
                moderatorId
        );

        return ResponseEntity.noContent()
                .build();
    }
    @GetMapping("/me")
    public ResponseEntity<AdminResponse> getModerator(

            @AuthenticationPrincipal
            AdminPrincipal admin
    ){
        return ResponseEntity.ok(adminModeratorService.getModerator(admin.getId()));
    }

}
