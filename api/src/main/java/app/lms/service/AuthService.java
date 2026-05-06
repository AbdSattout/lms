package app.lms.service;

import app.lms.Security.JwtService;
import app.lms.Security.UserPrincipal;
import app.lms.dto.AuthResponse;
import app.lms.dto.LoginRequest;
import app.lms.model.User;
import app.lms.repository.UserRepository;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {


    private final JwtDecoder telegramJwtDecoder;
    private final UserRepository userRepository;
    private final JwtService jwtService;

    public AuthService(
            @Qualifier("telegramJwtDecoder")
            JwtDecoder telegramJwtDecoder,
            UserRepository userRepository,
            JwtService jwtService
    ) {
        this.telegramJwtDecoder = telegramJwtDecoder;
        this.userRepository = userRepository;
        this.jwtService = jwtService;
    }

    public AuthResponse login(LoginRequest loginRequest) {
        Jwt telegramJwt =
                telegramJwtDecoder
                        .decode(loginRequest.getIdToken());
        String telegramId = telegramJwt.getClaim("id");
        String name = telegramJwt.getClaim("name");
        String picture = telegramJwt.getClaim("picture");
        User user = userRepository.findByTelegramId(telegramId)
                .orElseGet(()->{
                    User newUser = new User();
                    newUser.setTelegramId(telegramId);
                    newUser.setName(name);
                    newUser.setPicture(picture);
                    return userRepository.save(newUser);
                });
        String token = jwtService.generateToken(new UserPrincipal(user));
        return new AuthResponse(token , user);
    }
}
