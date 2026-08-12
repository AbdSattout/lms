package app.lms.chat.mapper;

import app.lms.chat.dto.MuteResponse;
import app.lms.chat.model.ChatMute;
import org.springframework.stereotype.Component;

@Component
public class MuteMapper {

    public MuteResponse toResponse(
            ChatMute mute
    ) {

        return new MuteResponse(
                mute.getId(),
                mute.getUser().getId(),
                mute.getCourse() != null
                        ? mute.getCourse().getId()
                        : null,
                mute.getConversation() != null
                        ? mute.getConversation().getId()
                        : null,
                mute.getMutedUntil(),
                mute.getReason(),
                mute.getCreatedBy().getId()
        );
    }
}
