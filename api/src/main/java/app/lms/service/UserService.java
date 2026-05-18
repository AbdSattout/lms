package app.lms.service;

import app.lms.dto.UpdateUserRequest;
import app.lms.dto.UserResponse;
import app.lms.enums.FileType;
import app.lms.model.User;
import app.lms.repository.UserRepository;
import lombok.AllArgsConstructor;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import app.lms.dto.UploadedFile;
@Service
@AllArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final MediaService mediaService;

    public UserResponse updatePicture(
            Long userId,
            MultipartFile image
    ) {

        if (image.isEmpty()) {
            throw new IllegalArgumentException("Image is required");
        }

        if (
                image.getContentType() == null ||
                        !image.getContentType().startsWith("image/")
        ) {
            throw new IllegalArgumentException("Invalid image type");
        }

        User user = userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new UsernameNotFoundException("User not found")
                );

        if (user.getPictureFileId() != null) {

            mediaService.delete(user.getPictureFileId());
        }

        UploadedFile uploadedFile =
                mediaService.upload(image, "/users" , FileType.IMAGE);

        user.setPicture(uploadedFile.url());
        user.setPictureFileId(uploadedFile.fileId());

        User updatedUser = userRepository.save(user);

        return new UserResponse(
                updatedUser.getId(),
                updatedUser.getName(),
                updatedUser.getPicture()
        );
    }

    public UserResponse updateUser(
            Long userId,
            UpdateUserRequest request
    ) {

        User user = userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new UsernameNotFoundException("User not found")
                );

        if (request.getName() != null) {
            user.setName(request.getName());
        }

        User updatedUser = userRepository.save(user);

        return new UserResponse(
                updatedUser.getId(),
                updatedUser.getName(),
                updatedUser.getPicture()
        );
    }

    public UserResponse getCurrentUser(
            Long userId
    ) {

        User user = userRepository
                .findById(userId)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "User not found"
                        )
                );

        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getPicture()
        );
    }
}
