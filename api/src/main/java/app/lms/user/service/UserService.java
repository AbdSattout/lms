package app.lms.user.service;

import app.lms.auth.enums.AuthProvider;
import app.lms.auth.service.EmailOtpService;
import app.lms.billing.mapper.SubscriptionMapper;
import app.lms.billing.repository.PolarSubscriptionRepository;
import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.service.MediaService;
import app.lms.plan.dto.UserPlanResponse;
import app.lms.plan.enums.PlanCode;
import app.lms.plan.mapper.UserPlanMapper;
import app.lms.plan.model.UserPlan;
import app.lms.plan.service.PlanQuotaService;
import app.lms.plan.service.UserPlanService;
import app.lms.user.dto.CurrentUserResponse;
import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.RequestUserEmailOtpRequest;
import app.lms.user.dto.UpdateUserRequest;
import app.lms.user.dto.UserResponse;
import app.lms.user.dto.VerifyUserEmailOtpRequest;
import app.lms.user.mapper.CurrentUserMapper;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

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
    private final LevelRepository levelRepository;
    private final UserProgressRepository userProgressRepository;
    private final UserPlanService userPlanService;
    private final PlanQuotaService planQuotaService;
    private final UserPlanMapper userPlanMapper;
    private final PolarSubscriptionRepository polarSubscriptionRepository;
    private final SubscriptionMapper subscriptionMapper;
    private final CurrentUserMapper currentUserMapper;
    private final EmailOtpService emailOtpService;

    @Transactional
    public UserResponse updatePicture(
            Long userId,
            MultipartFile image
    ) {

        User user = findUserById(userId);
        String oldPictureFileId =
                user.getPictureFileId();

        validateGifUploadAllowed(
                user,
                image
        );

        UploadedFile uploadedFile =
                mediaService.upload(
                        image,
                        "/users",
                        FileType.IMAGE,
                        true
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
    public void requestEmailOtp(
            Long userId,
            RequestUserEmailOtpRequest request
    ) {

        User user =
                findUserById(userId);

        validateCanSetLoginEmail(user);

        String normalizedEmail =
                normalizeEmail(
                        request.getEmail()
                );

        ensureEmailAvailable(
                normalizedEmail,
                user.getId()
        );

        emailOtpService.requestSetUserEmailOtp(
                normalizedEmail
        );
    }

    @Transactional
    public CurrentUserResponse verifyEmailOtp(
            Long userId,
            VerifyUserEmailOtpRequest request
    ) {

        User user =
                findUserById(userId);

        validateCanSetLoginEmail(user);

        String normalizedEmail =
                normalizeEmail(
                        request.getEmail()
                );

        ensureEmailAvailable(
                normalizedEmail,
                user.getId()
        );

        String verifiedEmail =
                emailOtpService.verifySetUserEmailOtp(
                        normalizedEmail,
                        request.getOtp()
                );

        ensureEmailAvailable(
                verifiedEmail,
                user.getId()
        );

        user.setEmail(verifiedEmail);

        try {
            userRepository.saveAndFlush(user);
        } catch (DataIntegrityViolationException ex) {
            throw new ConflictException(
                    "Email is already linked to another account"
            );
        }

        return getCurrentUser(
                user.getId()
        );
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

    @Transactional
    public CurrentUserResponse getCurrentUser(
            Long userId
    ) {

        User user =
                findUserById(userId);

        UserPlan userPlan =
                userPlanService.getOrCreateCurrentUserPlan(user);

        UserPlanResponse plan =
                userPlanMapper.toResponse(
                        userPlan.getPlan(),
                        userPlan,
                        userPlan.getPlan()
                                .getCode() == PlanCode.PREMIUM
                );

        return currentUserMapper.toResponse(
                user,
                plan,
                polarSubscriptionRepository
                        .findFirstByUserIdOrderByCreatedAtDesc(userId)
                        .map(subscriptionMapper::toResponse)
                        .orElse(null)
        );
    }

     public User findUserById(Long userId) {
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

        if (!StringUtils.hasText(email)) {
            throw new BadRequestException(
                    "Email is required"
            );
        }

        return email
                .trim()
                .toLowerCase(Locale.ROOT);
    }

    private void validateCanSetLoginEmail(
            User user
    ) {

        if (StringUtils.hasText(user.getEmail())) {
            throw new ConflictException(
                    "Email is already set and cannot be changed"
            );
        }
    }

    private void ensureEmailAvailable(
            String email,
            Long userId
    ) {

        if (userRepository.existsByEmailIgnoreCaseAndIdNot(
                email,
                userId
        )) {
            throw new ConflictException(
                    "Email is already linked to another account"
            );
        }
    }

    private void validateGifUploadAllowed(
            User user,
            MultipartFile image
    ) {

        if (!mediaService.isGif(image)) {
            return;
        }

        planQuotaService.validateGifUploadAllowed(user);
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
                        userMapper.toProfileResponse(
                                row.getUser(),
                                row.getProfile()
                        )
                )
                .toList();

    }

}
