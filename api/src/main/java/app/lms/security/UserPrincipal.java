package app.lms.security;

import app.lms.user.model.User;
import org.jspecify.annotations.NullMarked;
import org.jspecify.annotations.Nullable;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public record UserPrincipal(
        User user,
        boolean accountNonLocked
) implements UserDetails {

    @Override
    @NullMarked
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(
                new SimpleGrantedAuthority("ROLE_USER")
        );
    }

    @Override
    public @Nullable String getPassword() {
        return null;
    }

    @Override
    @NullMarked
    public String getUsername() {
        return user.getId().toString();
    }

    @Override
    @NullMarked
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    @NullMarked
    public boolean isAccountNonLocked() {
        return accountNonLocked;
    }

    @Override
    @NullMarked
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    @NullMarked
    public boolean isEnabled() {
        return true;
    }

    public static UserPrincipal from(
            User user
    ) {

        return new UserPrincipal(
                user,
                true
        );
    }

    public static UserPrincipal from(
            User user,
            boolean accountNonLocked
    ) {

        return new UserPrincipal(
                user,
                accountNonLocked
        );
    }

    public Long getId() {

        return user.getId();
    }

}
