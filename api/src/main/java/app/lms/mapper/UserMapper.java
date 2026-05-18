package app.lms.mapper;

import app.lms.dto.UserResponse;
import app.lms.model.User;
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
}