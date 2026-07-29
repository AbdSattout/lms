package app.lms.admin.service;

import app.lms.admin.dto.AdminAuthResponse;
import app.lms.admin.dto.AdminLoginRequest;
import app.lms.admin.mapper.AdminMapper;
import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import app.lms.admin.security.AdminPrincipal;
import app.lms.security.AuthPrincipalType;
import app.lms.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Locale;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AdminAuthService {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AdminMapper adminMapper;

    @Transactional
    public AdminAuthResponse login(
            AdminLoginRequest request
    ) {

        String email =
                normalizeEmail(
                        request.email()
                );

        Admin admin =
                adminRepository
                        .findByEmailIgnoreCase(email)
                        .orElseThrow(this::invalidCredentials);

        if (!Boolean.TRUE.equals(admin.getEnabled())) {
            throw invalidCredentials();
        }

        if (
                !passwordEncoder.matches(
                        request.password(),
                        admin.getPasswordHash()
                )
        ) {
            throw invalidCredentials();
        }

        admin.setLastLoginAt(
                LocalDateTime.now()
        );

        AdminPrincipal principal =
                AdminPrincipal.from(admin);

        String token =
                jwtService.generateToken(
                        Map.of(
                                JwtService.TOKEN_TYPE_CLAIM,
                                AuthPrincipalType.ADMIN.name(),
                                "role",
                                admin.getRole()
                                        .name()
                        ),
                        principal
                );

        return new AdminAuthResponse(
                token,
                adminMapper.toResponse(admin)
        );
    }

    private String normalizeEmail(
            String email
    ) {

        return email
                .trim()
                .toLowerCase(Locale.ROOT);
    }

    private BadCredentialsException invalidCredentials() {

        return new BadCredentialsException(
                "Invalid admin email or password"
        );
    }
}
