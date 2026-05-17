package app.lms.controller;


import app.lms.dto.ProfileResponse;
import app.lms.dto.UpdateProfile;
import app.lms.service.ProfileService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final ProfileService profileService;

    @GetMapping("/me")
    public ResponseEntity<ProfileResponse> getMyProfile() {
        return ResponseEntity.ok(
                profileService.getMyProfile()
        );
    }

    @PutMapping("/me")
    public ResponseEntity<ProfileResponse> updateProfile(
            @RequestBody UpdateProfile request
    ) {

        return ResponseEntity.ok(
                profileService.updateProfile(request)
        );
    }

    @DeleteMapping("/me")
    public ResponseEntity<?> deleteProfile() {
        profileService.deleteProfile();
        return ResponseEntity.ok().body(
                "Profile deleted"
        );
    }

}
