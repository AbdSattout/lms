package app.lms.controller;


import app.lms.dto.ProfileResponse;
import app.lms.dto.UpdateProfile;
import app.lms.security.UserPrincipal;
import app.lms.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/me")
    public ResponseEntity<ProfileResponse> getMyProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal
            ) {
        return ResponseEntity.ok(
                profileService.getMyProfile(userPrincipal.user())
        );
    }

    @PatchMapping("/me")
    public ResponseEntity<ProfileResponse> updateProfile(
            @RequestBody UpdateProfile request , @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {

        return ResponseEntity.ok(
                profileService.updateProfile(request , userPrincipal.user())
        );
    }

    @DeleteMapping("/me")
    public ResponseEntity<?> deleteProfile(
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        profileService.deleteProfile(userPrincipal.user());
        return ResponseEntity.ok().body(
                "Profile deleted"
        );
    }

}
