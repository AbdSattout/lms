package app.lms.user.controller;


import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.UpdateProfile;
import app.lms.security.UserPrincipal;
import app.lms.user.service.ProfileService;
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
            @AuthenticationPrincipal UserPrincipal userPrincipal,  @RequestBody UpdateProfile request
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
