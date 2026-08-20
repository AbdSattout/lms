package app.lms.chat.mapper;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.enums.ConversationType;
import app.lms.chat.model.Conversation;
import app.lms.user.dto.UserResponse;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ConversationMapper {

    private final UserMapper userMapper;

    public ConversationResponse toResponse(
            Conversation conversation,
            User currentUser
    ) {

        UserResponse directUser =
                directUser(
                        conversation,
                        currentUser
                );

        return new ConversationResponse(
                conversation.getId(),
                conversation.getType(),

                conversation.getCourse() != null
                        ? conversation.getCourse().getId()
                        : null,

                conversation.getDirectUserOne() != null
                        ? conversation.getDirectUserOne().getId()
                        : null,

                conversation.getDirectUserTwo() != null
                        ? conversation.getDirectUserTwo().getId()
                        : null,

                directUser,

                conversation.getLastMessagePreview(),
                conversation.getLastMessageAt()
        );
    }

    private UserResponse directUser(
            Conversation conversation,
            User currentUser
    ) {

        if (
                conversation.getType() != ConversationType.DIRECT
                        || currentUser == null
        ) {
            return null;
        }

        User otherUser;

        if (
                conversation.getDirectUserOne()
                        .getId()
                        .equals(currentUser.getId())
        ) {

            otherUser =
                    conversation.getDirectUserTwo();

        } else {

            otherUser =
                    conversation.getDirectUserOne();
        }

        return userMapper.toResponse(
                otherUser
        );
    }
}