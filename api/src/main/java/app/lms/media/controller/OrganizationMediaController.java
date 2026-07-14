package app.lms.media.controller;

import app.lms.media.dto.OrganizationMediaResponse;
import app.lms.media.dto.OrganizationMediaSummaryResponse;
import app.lms.media.service.OrganizationMediaService;
import app.lms.security.UserPrincipal;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/organizations/{slug}/media-library")
public class OrganizationMediaController {

    private final OrganizationMediaService organizationMediaService;

    @GetMapping
    public ResponseEntity<Page<OrganizationMediaResponse>> list(
            @PathVariable String slug,
            Pageable pageable,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationMediaService.list(
                        slug,
                        pageable,
                        principal.user()
                )
        );
    }

    @GetMapping("/summary")
    public ResponseEntity<OrganizationMediaSummaryResponse> summary(
            @PathVariable String slug,
            @AuthenticationPrincipal UserPrincipal principal
    ) {

        return ResponseEntity.ok(
                organizationMediaService.summary(
                        slug,
                        principal.user()
                )
        );
    }
}
