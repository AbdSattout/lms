package app.lms.chat.mapper;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.model.Conversation;
import app.lms.user.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ConversationMapper {

    private final UserMapper userMapper;

    public ConversationResponse toResponse(
            Conversation conversation
    ) {

        return new ConversationResponse(
                conversation.getId(),

                conversation.getType(),

                conversation.getCourse() != null
                        ? conversation.getCourse().getId()
                        : null,

                conversation.getDirectUserOne() != null
                        ? userMapper.toResponse(
                        conversation.getDirectUserOne()
                )
                        : null,

                conversation.getDirectUserTwo() != null
                        ? userMapper.toResponse(
                        conversation.getDirectUserTwo()
                )
                        : null,

                conversation.getLastMessagePreview(),

                conversation.getLastMessageAt()
        );
    }
}