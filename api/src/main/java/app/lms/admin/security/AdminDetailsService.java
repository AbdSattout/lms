package app.lms.admin.security;

import app.lms.admin.model.Admin;
import app.lms.admin.repository.AdminRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AdminDetailsService {

    private final AdminRepository adminRepository;

    public AdminPrincipal loadById(
            String adminId
    ) {

        long id;

        try {
            id = Long.parseLong(adminId);
        } catch (NumberFormatException ex) {
            throw new UsernameNotFoundException(
                    "Invalid admin id"
            );
        }

        Admin admin =
                adminRepository
                        .findById(id)
                        .orElseThrow(() ->
                                new UsernameNotFoundException(
                                        "Admin not found"
                                )
                        );

        return AdminPrincipal.from(admin);
    }
}
