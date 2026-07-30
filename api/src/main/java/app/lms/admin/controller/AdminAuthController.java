package app.lms.admin.controller;

import app.lms.admin.dto.AdminAuthResponse;
import app.lms.admin.dto.AdminLoginRequest;
import app.lms.admin.service.AdminAuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/auth")
public class AdminAuthController {

    private final AdminAuthService adminAuthService;

    @PostMapping("/login")
    public ResponseEntity<AdminAuthResponse> login(
            @RequestBody @Valid
            AdminLoginRequest request
    ) {

        return ResponseEntity.ok(
                adminAuthService.login(request)
        );
    }
}
