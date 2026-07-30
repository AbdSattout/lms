package app.lms.security;

import app.lms.admin.security.AdminDetailsService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class JwtPrincipalService {

    private final CustomUserDetailsService userDetailsService;
    private final AdminDetailsService adminDetailsService;

    public UserDetails loadUserDetails(
            AuthPrincipalType principalType,
            String subject
    ) {

        return switch (principalType) {
            case USER ->
                    userDetailsService.loadUserByUsername(
                            subject
                    );
            case ADMIN ->
                    adminDetailsService.loadById(
                            subject
                    );
        };
    }
}
