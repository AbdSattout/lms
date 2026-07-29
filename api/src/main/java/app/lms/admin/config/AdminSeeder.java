package app.lms.admin.config;

import app.lms.admin.enums.AdminRole;
import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.Locale;

@Component
@RequiredArgsConstructor
public class AdminSeeder implements ApplicationRunner {

    private final AdminRepository adminRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${app.admin.seed.email:}")
    private String email;

    @Value("${app.admin.seed.password:}")
    private String password;

    @Value("${app.admin.seed.name:Super Admin}")
    private String name;

    @Override
    @Transactional
    public void run(
            ApplicationArguments args
    ) {

        if (
                !StringUtils.hasText(email) ||
                        !StringUtils.hasText(password)
        ) {
            return;
        }

        String normalizedEmail =
                email.trim()
                        .toLowerCase(Locale.ROOT);

        if (
                adminRepository.existsByEmailIgnoreCase(
                        normalizedEmail
                )
        ) {
            return;
        }

        adminRepository.save(
                Admin.builder()
                        .name(seedName())
                        .email(normalizedEmail)
                        .passwordHash(
                                passwordEncoder.encode(password)
                        )
                        .role(AdminRole.SUPER_ADMIN)
                        .enabled(true)
                        .build()
        );
    }

    private String seedName() {

        if (!StringUtils.hasText(name)) {
            return "Super Admin";
        }

        return name.trim();
    }
}
