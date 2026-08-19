package app.lms.admin.service;

import app.lms.admin.dto.AdminResponse;
import app.lms.admin.dto.CreateModeratorRequest;
import app.lms.admin.enums.AdminRole;
import app.lms.admin.mapper.AdminMapper;
import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AdminModeratorService {

    private final AdminModerationAccessService accessService;
    private final AdminRepository adminRepository;
    private final AdminMapper adminMapper;
    private final PasswordEncoder passwordEncoder;

    @Transactional(readOnly = true)
    public Page<AdminResponse> listModerators(
            Long adminId,
            Pageable pageable
    ) {

        validateSuperAdmin(adminId);

        return adminRepository
                .findAllByRole(
                        AdminRole.MODERATOR,
                        pageable
                )
                .map(adminMapper::toResponse);
    }

    @Transactional
    public AdminResponse createModerator(
            Long adminId,
            CreateModeratorRequest request
    ) {

        validateSuperAdmin(adminId);

        String email =
                normalizeEmail(
                        request.email()
                );

        if (
                adminRepository.existsByEmailIgnoreCase(
                        email
                )
        ) {
            throw new ConflictException(
                    "Admin email already exists"
            );
        }

        Admin moderator =
                Admin.builder()
                        .name(request.name().trim())
                        .email(email)
                        .passwordHash(
                                passwordEncoder.encode(
                                        request.password()
                                )
                        )
                        .role(AdminRole.MODERATOR)
                        .enabled(true)
                        .seeded(false)
                        .build();

        return adminMapper.toResponse(
                adminRepository.save(moderator)
        );
    }

    @Transactional
    public void deleteModerator(
            Long adminId,
            Long moderatorId
    ) {

        validateSuperAdmin(adminId);

        Admin moderator =
                adminRepository
                        .findById(moderatorId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Moderator not found"
                                )
                        );

        if (moderator.getRole() != AdminRole.MODERATOR) {
            throw new BadRequestException(
                    "Only moderator accounts can be deleted"
            );
        }

        adminRepository.delete(moderator);
    }
    public AdminResponse getModerator(Long adminId){
        Admin admin =  adminRepository.findById(adminId).orElseThrow(() -> new  NotFoundException(
                "Admin not found"
        ));
        return adminMapper.toResponse(admin);
    }

    private void validateSuperAdmin(
            Long adminId
    ) {

        Admin admin =
                accessService.getAdmin(
                        adminId
                );

        accessService.validateSuperAdmin(admin);
    }

    private String normalizeEmail(
            String email
    ) {

        return email.trim()
                .toLowerCase(Locale.ROOT);
    }
}
