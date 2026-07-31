package app.lms.auth.service;

import app.lms.auth.dto.AuthResponse;
import app.lms.auth.dto.VerifyEmailOtpRequest;
import app.lms.security.JwtService;
import app.lms.user.dto.UserResponse;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.service.UserService;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.oauth2.jwt.JwtDecoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AuthServiceTest {

    private final JwtDecoder telegramJwtDecoder =
            mock(JwtDecoder.class);
    private final JwtDecoder googleJwtDecoder =
            mock(JwtDecoder.class);
    private final JwtService jwtService =
            mock(JwtService.class);
    private final UserMapper userMapper =
            mock(UserMapper.class);
    private final UserService userService =
            mock(UserService.class);
    private final EmailOtpService emailOtpService =
            mock(EmailOtpService.class);

    private final AuthService authService =
            new AuthService(
                    telegramJwtDecoder,
                    googleJwtDecoder,
                    jwtService,
                    userMapper,
                    userService,
                    emailOtpService
            );

    @Test
    void loginWithEmailOtpConsumesOtpAfterAuthResponseIsCreated() {

        VerifyEmailOtpRequest request =
                request(
                        "User@Example.com",
                        "123456"
                );

        User user =
                user();

        UserResponse userResponse =
                new UserResponse(
                        7L,
                        "user",
                        null,
                        null
                );

        when(emailOtpService.verifyOtpWithoutConsuming(
                "User@Example.com",
                "123456"
        ))
                .thenReturn("user@example.com");
        when(userService.getOrCreateEmailUser("user@example.com"))
                .thenReturn(user);
        when(jwtService.generateToken(any(UserDetails.class)))
                .thenReturn("jwt-token");
        when(userMapper.toResponse(user))
                .thenReturn(userResponse);

        AuthResponse response =
                authService.loginWithEmailOtp(request);

        assertEquals(
                "jwt-token",
                response.token()
        );
        assertSame(
                userResponse,
                response.user()
        );

        InOrder order =
                inOrder(
                        emailOtpService,
                        userService,
                        jwtService,
                        userMapper
                );

        order.verify(emailOtpService)
                .verifyOtpWithoutConsuming(
                        "User@Example.com",
                        "123456"
                );
        order.verify(userService)
                .getOrCreateEmailUser("user@example.com");
        order.verify(jwtService)
                .generateToken(any(UserDetails.class));
        order.verify(userMapper)
                .toResponse(user);
        order.verify(emailOtpService)
                .consumeOtp("user@example.com");
    }

    @Test
    void loginWithEmailOtpDoesNotConsumeOtpWhenTokenCreationFails() {

        VerifyEmailOtpRequest request =
                request(
                        "user@example.com",
                        "123456"
                );

        User user =
                user();

        when(emailOtpService.verifyOtpWithoutConsuming(
                "user@example.com",
                "123456"
        ))
                .thenReturn("user@example.com");
        when(userService.getOrCreateEmailUser("user@example.com"))
                .thenReturn(user);
        when(jwtService.generateToken(any(UserDetails.class)))
                .thenThrow(new IllegalStateException("bad jwt secret"));

        IllegalStateException exception =
                assertThrows(
                        IllegalStateException.class,
                        () -> authService.loginWithEmailOtp(request)
                );

        assertEquals(
                "bad jwt secret",
                exception.getMessage()
        );
        verify(emailOtpService, never())
                .consumeOtp(anyString());
    }

    private VerifyEmailOtpRequest request(
            String email,
            String otp
    ) {

        VerifyEmailOtpRequest request =
                new VerifyEmailOtpRequest();

        request.setEmail(email);
        request.setOtp(otp);

        return request;
    }

    private User user() {

        User user =
                new User();

        user.setId(7L);
        user.setEmail("user@example.com");
        user.setName("user");

        return user;
    }
}
