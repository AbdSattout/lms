package app.lms.friend.mapper;

import app.lms.friend.dto.FriendRequestResponse;
import app.lms.friend.model.FriendRequest;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class FriendMapper {

    private final UserMapper userMapper;

    public FriendRequestResponse toResponse(
            FriendRequest request
    ) {
        return new FriendRequestResponse(

                request.getId(),

                userMapper.toResponse(
                        request.getSender()
                ),

                userMapper.toResponse(
                        request.getReceiver()
                ),

                request.getStatus(),

                request.getCreatedAt()
        );
    }

}
