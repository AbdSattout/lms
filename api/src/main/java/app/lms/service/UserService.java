package app.lms.service;

import app.lms.dto.UpdateUserRequest;
import app.lms.dto.UserResponse;
import app.lms.enums.FileType;
import app.lms.mapper.UserMapper;
import app.lms.model.User;
import app.lms.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;
import app.lms.dto.UploadedFile;
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
    public User getOrCreateUser(
            Jwt telegramJwt
    ) {

        String telegramId =
                telegramJwt.getClaim("id");

        String name =
                telegramJwt.getClaim("name");

        String picture =
                telegramJwt.getClaim("picture");

        return userRepository
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
    }
}
