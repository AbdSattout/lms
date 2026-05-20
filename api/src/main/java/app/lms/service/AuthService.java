package app.lms.service;

import app.lms.mapper.UserMapper;
import app.lms.security.JwtService;
import app.lms.security.UserPrincipal;
import app.lms.dto.AuthResponse;
import app.lms.dto.LoginRequest;
import app.lms.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {


    private final JwtDecoder telegramJwtDecoder;
    private final JwtService jwtService;
    private final UserMapper userMapper;
    private final UserService userService;


    public AuthResponse login(
            LoginRequest loginRequest
    ) {

        Jwt telegramJwt =
                decodeTelegramToken(
                        loginRequest.getIdToken()
                );

        User user =
                userService.getOrCreateUser(
                        telegramJwt
                );

        String token =
                jwtService.generateToken(
                         UserPrincipal.from(user)
                );

        return new AuthResponse(
                token,
                userMapper.toResponse(user)
        );
    }

    private Jwt decodeTelegramToken(
            String idToken
    ) {

        try {

            return telegramJwtDecoder.decode(
                    idToken
            );

        } catch (Exception e) {

            throw new BadCredentialsException(
                    "Invalid Telegram idToken"
            );
        }
    }


}
