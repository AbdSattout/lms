package app.lms.chat.mapper;

import app.lms.chat.dto.MessageResponse;
import app.lms.chat.model.Message;
import org.springframework.stereotype.Component;

@Component
public class MessageMapper {

    public MessageResponse toResponse(
            Message message
    ) {

        return new MessageResponse(
                message.getId(),
                message.getConversation().getId(),
                message.getSender().getId(),
                message.getSender().getName(),
                message.getDeletedAt() != null
                        ? null
                        : message.getContent(),
                message.getType(),
                message.getCreatedAt(),
                message.getEditedAt(),
                message.getDeletedAt()

        );
    }
}
