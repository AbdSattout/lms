package app.lms.user.controller;


import app.lms.security.UserPrincipal;
import app.lms.user.dto.CurrentUserResponse;
import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.PublicUserProfileResponse;
import app.lms.user.dto.RequestUserEmailOtpRequest;
import app.lms.user.dto.UpdateUserRequest;
import app.lms.user.dto.UserResponse;
import app.lms.user.dto.VerifyUserEmailOtpRequest;
import app.lms.user.service.PublicUserProfileService;
import app.lms.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
public class UserController {

    private final UserService userService;
    private final PublicUserProfileService publicUserProfileService;


    @PatchMapping("/me")
    public ResponseEntity<UserResponse> updateUser(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody @Valid UpdateUserRequest request
    ) {

        UserResponse updatedUser = userService.updateUser(
                userPrincipal.getId(),
                request
        );

        return ResponseEntity.ok(updatedUser);
    }
    @PatchMapping(
            value = "/me/picture",
            consumes = MediaType.MULTIPART_FORM_DATA_VALUE
    )
    public ResponseEntity<UserResponse> updatePicture(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestParam("image") MultipartFile image
    ) {

        UserResponse updatedUser =
                userService.updatePicture(
                        userPrincipal.getId(),
                        image
                );

        return ResponseEntity.ok(updatedUser);
    }

    @PostMapping("/me/email/request-otp")
    public ResponseEntity<Void> requestEmailOtp(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody @Valid RequestUserEmailOtpRequest request
    ) {

        userService.requestEmailOtp(
                userPrincipal.getId(),
                request
        );

        return ResponseEntity
                .noContent()
                .build();
    }

    @PostMapping("/me/email/verify-otp")
    public ResponseEntity<CurrentUserResponse> verifyEmailOtp(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody @Valid VerifyUserEmailOtpRequest request
    ) {

        return ResponseEntity.ok(
                userService.verifyEmailOtp(
                        userPrincipal.getId(),
                        request
                )
        );
    }


    @GetMapping("/me")
    public ResponseEntity<CurrentUserResponse> getCurrentUser(
            @AuthenticationPrincipal
            UserPrincipal userPrincipal
    ) {

        CurrentUserResponse user =
                userService.getCurrentUser(
                        userPrincipal.getId()
                );

        return ResponseEntity.ok(user);
    }

    @GetMapping("/search")
    public List<ProfileResponse> search(
            @RequestParam String q,
            @AuthenticationPrincipal UserPrincipal userPrincipal

    ){

        return userService.search(
                q,
                userPrincipal.getId()
        );

    }

    @GetMapping("/{userId}/profile")
    public ResponseEntity<PublicUserProfileResponse> getProfile(
            @PathVariable
            Long userId,

            @AuthenticationPrincipal
            UserPrincipal userPrincipal
    ) {

        return ResponseEntity.ok(
                publicUserProfileService.getProfile(
                        userId,
                        userPrincipal.user()
                )
        );
    }

}
