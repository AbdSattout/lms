package app.lms.user.service;

import app.lms.auth.enums.AuthProvider;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.UpdateUserRequest;
import app.lms.user.dto.UserResponse;
import app.lms.media.enums.FileType;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import app.lms.media.service.MediaService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import app.lms.media.dto.UploadedFile;

import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UserService {

    private static final Logger logger =
            LoggerFactory.getLogger(
                    UserService.class
            );
    private final UserRepository userRepository;
    private final MediaService mediaService;
    private final UserMapper userMapper;
    private final UserMapper mapper;
    private final LevelRepository levelRepository;
    private final UserProgressRepository userProgressRepository;

    @Transactional
    public UserResponse updatePicture(
            Long userId,
            MultipartFile image
    ) {

        User user = findUserById(userId);
        String oldPictureFileId =
                user.getPictureFileId();

        UploadedFile uploadedFile =
                mediaService.upload(
                        image,
                        "/users",
                        FileType.IMAGE
                );

        user.setPicture(uploadedFile.url());
        user.setPictureFileId(uploadedFile.fileId());

        User updatedUser =
                userRepository.save(user);

        if (oldPictureFileId != null) {

            try {

                mediaService.delete(oldPictureFileId);

            } catch (Exception e) {
                logger.warn(
                        "Failed to delete old profile picture: {}",
                        oldPictureFileId,
                        e
                );
            }
        }


        return userMapper.toResponse(updatedUser);
    }

    @Transactional
    public UserResponse updateUser(
            Long userId,
            UpdateUserRequest request
    ) {

        User user = findUserById(userId);
        if (request.getName() != null) {
            user.setName(request.getName());
        }

        if (request.getUsername() != null) {
            updateUsername(
                    user,
                    request.getUsername()
            );
        }

        User updatedUser = userRepository.save(user);

        return userMapper.toResponse(updatedUser);
    }

    public UserResponse getCurrentUser(
            Long userId
    ) {

        User user = findUserById(userId);

        return userMapper.toResponse(user);
    }


    private User findUserById(Long userId) {
        return userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "User not found"
                        )
                );
    }
    @Transactional
    public User getOrCreateUser(
            AuthProvider provider,
            Jwt externalJwt
    ) {

        return switch (provider) {
            case TELEGRAM -> getOrCreateTelegramUser(externalJwt);
            case GOOGLE -> getOrCreateGoogleUser(externalJwt);
        };
    }

    @Transactional
    public User getOrCreateEmailUser(
            String email
    ) {

        String normalizedEmail =
                normalizeEmail(email);

        User user =
                userRepository
                        .findByEmailIgnoreCase(normalizedEmail)
                        .orElseGet(() -> {

                            User newUser = new User();

                            newUser.setEmail(normalizedEmail);
                            newUser.setName(
                                    defaultNameFromEmail(
                                            normalizedEmail
                                    )
                            );

                            return newUser;
                        });

        user = userRepository.save(user);

        ensureProgressExists(user);

        return user;
    }

    private User getOrCreateTelegramUser(
            Jwt telegramJwt
    ) {

        String telegramId =
                requiredClaim(
                        telegramJwt,
                        "id",
                        AuthProvider.TELEGRAM
                );

        String name =
                telegramJwt.getClaimAsString("name");

        String picture =
                telegramJwt.getClaimAsString("picture");

        User user =
                userRepository
                .findByTelegramId(telegramId)
                .orElseGet(() -> {

                    User newUser = new User();

                    newUser.setTelegramId(
                            telegramId
                    );
                    newUser.setName(name);

                    return newUser;
                });

        if (!StringUtils.hasText(user.getPictureFileId())) {
            user.setPicture(picture);
        }

        user = userRepository.save(user);

        ensureProgressExists(user);

        return user;
    }

    private User getOrCreateGoogleUser(
            Jwt googleJwt
    ) {

        String googleId =
                requiredClaim(
                        googleJwt,
                        "sub",
                        AuthProvider.GOOGLE
                );

        String name =
                googleJwt.getClaimAsString("name");

        String picture =
                googleJwt.getClaimAsString("picture");

        String email =
                googleJwt.getClaimAsString("email");

        boolean emailVerified =
                isTrue(
                        googleJwt.getClaim("email_verified")
                );

        User user =
                findOrCreateGoogleUser(
                        googleId,
                        name,
                        email,
                        emailVerified
                );

        attachVerifiedEmailIfAvailable(
                user,
                email,
                emailVerified
        );

        if (!StringUtils.hasText(user.getPictureFileId())) {
            user.setPicture(picture);
        }

        user = userRepository.save(user);

        ensureProgressExists(user);

        return user;
    }

    private String requiredClaim(
            Jwt jwt,
            String claim,
            AuthProvider provider
    ) {

        Object value =
                jwt.getClaim(claim);

        if (value == null ||
                !StringUtils.hasText(value.toString())) {
            throw new BadCredentialsException(
                    "Missing " + provider.name().toLowerCase() +
                            " " + claim + " claim"
            );
        }

        return value.toString();
    }

    private User findOrCreateGoogleUser(
            String googleId,
            String name,
            String email,
            boolean emailVerified
    ) {

        return userRepository
                .findByGoogleId(googleId)
                .orElseGet(() ->
                        findEmailUserForGoogle(
                                googleId,
                                email,
                                emailVerified
                        )
                                .orElseGet(() -> {

                                    User newUser = new User();

                                    newUser.setGoogleId(googleId);
                                    newUser.setName(name);

                                    if (emailVerified &&
                                            StringUtils.hasText(email)) {
                                        newUser.setEmail(
                                                normalizeEmail(email)
                                        );
                                    }

                                    return newUser;
                                })
                );
    }

    private Optional<User> findEmailUserForGoogle(
            String googleId,
            String email,
            boolean emailVerified
    ) {

        if (!emailVerified ||
                !StringUtils.hasText(email)) {
            return Optional.empty();
        }

        return userRepository
                .findByEmailIgnoreCase(
                        normalizeEmail(email)
                )
                .map(user -> {

                    if (StringUtils.hasText(user.getGoogleId()) &&
                            !user.getGoogleId().equals(googleId)) {
                        throw new ConflictException(
                                "Email is already linked to another Google account"
                        );
                    }

                    if (!StringUtils.hasText(user.getGoogleId())) {
                        user.setGoogleId(
                                googleId
                        );
                    }

                    return user;
                });
    }

    private void attachVerifiedEmailIfAvailable(
            User user,
            String email,
            boolean emailVerified
    ) {

        if (!emailVerified ||
                !StringUtils.hasText(email) ||
                StringUtils.hasText(user.getEmail())) {
            return;
        }

        String normalizedEmail =
                normalizeEmail(email);

        if (user.getId() != null &&
                userRepository.existsByEmailIgnoreCaseAndIdNot(
                        normalizedEmail,
                        user.getId()
                )) {
            return;
        }

        user.setEmail(normalizedEmail);
    }

    private boolean isTrue(
            Object value
    ) {

        if (value instanceof Boolean booleanValue) {
            return booleanValue;
        }

        if (value instanceof String stringValue) {
            return Boolean.parseBoolean(stringValue);
        }

        return false;
    }

    private String normalizeEmail(
            String email
    ) {

        return email
                .trim()
                .toLowerCase(Locale.ROOT);
    }

    private String defaultNameFromEmail(
            String email
    ) {

        int atIndex =
                email.indexOf('@');

        if (atIndex <= 0) {
            return email;
        }

        return email.substring(0, atIndex);
    }

    private void updateUsername(
            User user,
            String username
    ) {

        String normalizedUsername =
                username.trim();

        if (!normalizedUsername.matches("^[a-z0-9_]{3,30}$")) {
            throw new BadRequestException(
                    "Username must be 3-30 characters and contain only lowercase letters, numbers, and underscores"
            );
        }

        if (userRepository.existsByUsernameIgnoreCaseAndIdNot(
                normalizedUsername,
                user.getId()
        )) {
            throw new ConflictException(
                    "Username is already taken"
            );
        }

        user.setUsername(normalizedUsername);
    }

    private void ensureProgressExists(
            User user
    ) {

        if (userProgressRepository.existsByUserId(user.getId())) {
            return;
        }

        Level initialLevel =
                levelRepository
                        .findByLevelNumber(1)
                        .orElse(null);

        UserProgress progress =
                UserProgress.builder()
                        .user(user)
                        .totalXp(0)
                        .currentLevel(initialLevel)
                        .build();

        userProgressRepository.save(progress);
    }
    public List<ProfileResponse> search(String q){

        String searchQuery =
                q == null ? "" : q.trim();

        String usernameQ =
                searchQuery;

        if (StringUtils.hasText(usernameQ) &&
                usernameQ.startsWith("@")) {
            usernameQ =
                    usernameQ.substring(1);
        }

        return userRepository.searchWithProfile(
                        searchQuery,
                        usernameQ
                )
                .stream()
                .map(row ->
                        mapper.toProfileResponse(
                                row.getUser(),
                                row.getProfile()
                        )
                )
                .toList();

    }

}
