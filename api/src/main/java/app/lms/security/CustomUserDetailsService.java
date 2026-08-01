package app.lms.security;

import app.lms.user.model.User;
import app.lms.user.moderation.repository.UserModerationRepository;
import app.lms.user.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.jspecify.annotations.NullMarked;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final UserModerationRepository userModerationRepository;

    @Override
    @NullMarked
    public UserDetails loadUserByUsername(String userId) throws UsernameNotFoundException {
        long id;
        try {

            id = Long.parseLong(userId);

        } catch (NumberFormatException e) {

            throw new UsernameNotFoundException(
                    "Invalid user id"
            );
        }
        User user = userRepository.findById(id)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "User not found"
                        )
                );

        return UserPrincipal.from(
                user,
                !userModerationRepository.existsByUserId(
                        user.getId()
                )
        );
    }
}
