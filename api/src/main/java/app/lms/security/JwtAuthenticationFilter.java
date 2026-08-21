package app.lms.security;


import app.lms.common.exception.CustomAuthenticationEntryPoint;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.http.MediaType;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Map;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final JwtPrincipalService jwtPrincipalService;
    private final CustomAuthenticationEntryPoint
            authenticationEntryPoint;
    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {
        final String authHeader = request.getHeader("Authorization");
        final String jwt;
        final String username;
        final AuthPrincipalType principalType;
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }
        jwt = authHeader.substring(7);

        try {

            username = jwtService.extractUsername(jwt);
            principalType =
                    jwtService.extractPrincipalType(jwt);

        } catch (Exception ex) {

            SecurityContextHolder.clearContext();

            authenticationEntryPoint.commence(
                    request,
                    response,
                    new BadCredentialsException(
                            "Invalid JWT"
                    )
            );

            return;
        }
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                UserDetails userDetails =
                        jwtPrincipalService.loadUserDetails(
                                principalType,
                                username
                        );
                if (userDetails instanceof UserPrincipal principal && !principal.isAccountNonLocked()) {
                    writeUserBannedResponse(response);
                    return;
                }
                if (jwtService.isTokenValid(jwt, userDetails)) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            userDetails, null, userDetails.getAuthorities()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }

            }catch (Exception ex) {

                SecurityContextHolder.clearContext();

                authenticationEntryPoint.commence(
                        request,
                        response,
                        new
                                BadCredentialsException(
                                ex.getMessage()
                        )
                );

                return;
            }
        }
        filterChain.doFilter(request, response);

    }

    private void writeUserBannedResponse(HttpServletResponse response) throws IOException {
        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);

        new ObjectMapper().writeValue(
                response.getOutputStream(),
                Map.of(
                        "status", 403,
                        "error", "User is banned",
                        "code", "USER_BANNED"
                )
        );
    }
}

