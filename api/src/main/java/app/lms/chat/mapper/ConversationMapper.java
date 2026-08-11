package app.lms.chat.mapper;

import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.model.Conversation;
import org.springframework.stereotype.Component;

@Component
public class ConversationMapper {

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
                        ? conversation
                        .getDirectUserOne()
                        .getId()
                        : null,
                conversation.getDirectUserTwo() != null
                        ? conversation
                        .getDirectUserTwo()
                        .getId()
                        : null,
                conversation.getLastMessagePreview(),
                conversation.getLastMessageAt()
        );
    }
}
