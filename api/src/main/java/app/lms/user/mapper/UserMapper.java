package app.lms.user.mapper;

import app.lms.user.dto.ProfileResponse;
import app.lms.user.dto.UserResponse;
import app.lms.user.model.Profile;
import app.lms.user.model.User;
import org.springframework.stereotype.Component;

@Component
public class UserMapper {

    public UserResponse toResponse(
            User user
    ) {

        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getPicture()
        );
    }
    public ProfileResponse toProfileResponse(User user, Profile profile) {

        return ProfileResponse.builder()
                .name(user.getName())
                .email(profile.getEmail())
                .phone(profile.getPhone())
                .university(profile.getUniversity())
                .build();
    }
}