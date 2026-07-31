package app.lms.auth.controller;

import app.lms.auth.dto.EmailOtpRequest;
import app.lms.auth.dto.AuthResponse;
import app.lms.auth.dto.LoginRequest;
import app.lms.auth.dto.VerifyEmailOtpRequest;
import app.lms.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login/telegram")
    public ResponseEntity<AuthResponse> loginWithTelegram(
            @RequestBody @Valid LoginRequest loginRequest
    ) {
        AuthResponse response =
                authService.loginWithTelegram(loginRequest);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(
            @RequestBody @Valid LoginRequest loginRequest
    ) {
        AuthResponse response =
                authService.loginWithTelegram(loginRequest);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login/google")
    public ResponseEntity<AuthResponse> loginWithGoogle(
            @RequestBody @Valid LoginRequest loginRequest
    ) {
        AuthResponse response =
                authService.loginWithGoogle(loginRequest);

        return ResponseEntity.ok(response);
    }

    @PostMapping("/login/email/request-otp")
    public ResponseEntity<Void> requestEmailOtp(
            @RequestBody @Valid EmailOtpRequest request
    ) {

        authService.requestEmailOtp(request);

        return ResponseEntity.noContent().build();
    }

    @PostMapping("/login/email/verify-otp")
    public ResponseEntity<AuthResponse> loginWithEmailOtp(
            @RequestBody @Valid VerifyEmailOtpRequest request
    ) {
        AuthResponse response =
                authService.loginWithEmailOtp(request);

        return ResponseEntity.ok(response);
    }

}
