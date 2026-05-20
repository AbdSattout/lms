package app.lms.controller;


import app.lms.dto.UpdateUserRequest;
import app.lms.dto.UserResponse;
import app.lms.security.UserPrincipal;
import app.lms.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
public class UserController {

    private final UserService userService;


    @PatchMapping("/me")
    public ResponseEntity<UserResponse> updateUser(
            @AuthenticationPrincipal UserPrincipal userPrincipal,
            @RequestBody UpdateUserRequest request
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


    @GetMapping("/me")
    public ResponseEntity<UserResponse> getCurrentUser(
            @AuthenticationPrincipal
            UserPrincipal userPrincipal
    ) {

        UserResponse user =
                userService.getCurrentUser(
                        userPrincipal.getId()
                );

        return ResponseEntity.ok(user);
    }



}
