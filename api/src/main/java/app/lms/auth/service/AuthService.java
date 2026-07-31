package app.lms.auth.service;

import app.lms.auth.dto.AuthResponse;
import app.lms.auth.dto.EmailOtpRequest;
import app.lms.auth.dto.LoginRequest;
import app.lms.auth.dto.VerifyEmailOtpRequest;
import app.lms.auth.enums.AuthProvider;
import app.lms.security.JwtService;
import app.lms.security.UserPrincipal;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.service.UserService;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {


    private final JwtDecoder telegramJwtDecoder;
    private final JwtDecoder googleJwtDecoder;
    private final JwtService jwtService;
    private final UserMapper userMapper;
    private final UserService userService;
    private final EmailOtpService emailOtpService;

    public AuthService(
            @Qualifier("telegramJwtDecoder") JwtDecoder telegramJwtDecoder,
            @Qualifier("googleJwtDecoder") JwtDecoder googleJwtDecoder,
            JwtService jwtService,
            UserMapper userMapper,
            UserService userService,
            EmailOtpService emailOtpService
    ) {
        this.telegramJwtDecoder =
                telegramJwtDecoder;
        this.googleJwtDecoder =
                googleJwtDecoder;
        this.jwtService =
                jwtService;
        this.userMapper =
                userMapper;
        this.userService =
                userService;
        this.emailOtpService =
                emailOtpService;
    }

    public AuthResponse loginWithTelegram(
            LoginRequest loginRequest
    ) {

        return loginWithProvider(
                loginRequest,
                AuthProvider.TELEGRAM,
                telegramJwtDecoder
        );
    }

    public AuthResponse loginWithGoogle(
            LoginRequest loginRequest
    ) {

        return loginWithProvider(
                loginRequest,
                AuthProvider.GOOGLE,
                googleJwtDecoder
        );
    }

    public void requestEmailOtp(
            EmailOtpRequest request
    ) {

        emailOtpService.requestOtp(
                request.getEmail()
        );
    }

    public AuthResponse loginWithEmailOtp(
            VerifyEmailOtpRequest request
    ) {

        String email =
                emailOtpService.verifyOtpWithoutConsuming(
                        request.getEmail(),
                        request.getOtp()
                );

        User user =
                userService.getOrCreateEmailUser(email);

        AuthResponse response =
                createAuthResponse(user);

        emailOtpService.consumeOtp(email);

        return response;
    }

    private AuthResponse loginWithProvider(
            LoginRequest loginRequest,
            AuthProvider provider,
            JwtDecoder jwtDecoder
    ) {

        Jwt externalJwt =
                decodeToken(
                        loginRequest.getIdToken(),
                        provider,
                        jwtDecoder
                );

        User user =
                userService.getOrCreateUser(
                        provider,
                        externalJwt
                );

        return createAuthResponse(user);
    }

    private AuthResponse createAuthResponse(
            User user
    ) {

        String token =
                jwtService.generateToken(
                         UserPrincipal.from(user)
                );

        return new AuthResponse(
                token,
                userMapper.toResponse(user)
        );
    }

    private Jwt decodeToken(
            String idToken,
            AuthProvider provider,
            JwtDecoder jwtDecoder
    ) {

        try {

            return jwtDecoder.decode(
                    idToken
            );

        } catch (Exception e) {

            throw new BadCredentialsException(
                    "Invalid " + provider.name().toLowerCase() + " idToken"
            );
        }
    }


}
