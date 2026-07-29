package app.lms.admin.security;

import app.lms.admin.model.Admin;
import org.jspecify.annotations.NullMarked;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

public record AdminPrincipal(Admin admin) implements UserDetails {

    @Override
    @NullMarked
    public Collection<? extends GrantedAuthority> getAuthorities() {

        return List.of(
                new SimpleGrantedAuthority("ROLE_ADMIN"),
                new SimpleGrantedAuthority(
                        "ADMIN:" + admin.getRole()
                                .name()
                )
        );
    }

    @Override
    @NullMarked
    public String getPassword() {

        return admin.getPasswordHash();
    }

    @Override
    @NullMarked
    public String getUsername() {

        return admin.getId()
                .toString();
    }

    @Override
    @NullMarked
    public boolean isAccountNonExpired() {

        return true;
    }

    @Override
    @NullMarked
    public boolean isAccountNonLocked() {

        return true;
    }

    @Override
    @NullMarked
    public boolean isCredentialsNonExpired() {

        return true;
    }

    @Override
    @NullMarked
    public boolean isEnabled() {

        return Boolean.TRUE.equals(
                admin.getEnabled()
        );
    }

    public static AdminPrincipal from(
            Admin admin
    ) {

        return new AdminPrincipal(admin);
    }

    public Long getId() {

        return admin.getId();
    }
}
