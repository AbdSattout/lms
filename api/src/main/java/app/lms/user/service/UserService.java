package app.lms.user.service;

import app.lms.gamification.model.Level;
import app.lms.gamification.model.UserProgress;
import app.lms.gamification.repository.LevelRepository;
import app.lms.gamification.repository.UserProgressRepository;
import app.lms.user.dto.UpdateUserRequest;
import app.lms.user.dto.UserResponse;
import app.lms.media.enums.FileType;
import app.lms.user.dto.UserSearchResponse;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.repository.ProfileRepository;
import app.lms.user.repository.UserRepository;
import app.lms.media.service.MediaService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import app.lms.media.dto.UploadedFile;

import java.util.List;

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
    private final ProfileRepository profileRepository;
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
            Jwt telegramJwt
    ) {

        String telegramId =
                telegramJwt.getClaim("id");

        String name =
                telegramJwt.getClaim("name");

        String picture =
                telegramJwt.getClaim("picture");

        User user =
                userRepository
                .findByTelegramId(telegramId)
                .orElseGet(() -> {

                    User newUser = new User();

                    newUser.setTelegramId(
                            telegramId
                    );

                    newUser.setName(name);

                    newUser.setPicture(picture);

                    return userRepository.save(
                            newUser
                    );
                });

        ensureProgressExists(user);

        return user;
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
    public List<UserSearchResponse> search(String q){

        return profileRepository.search(q)
                .stream()
                .map(mapper::toSearchResponse)
                .toList();

    }

}
