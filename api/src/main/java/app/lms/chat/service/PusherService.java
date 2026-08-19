package app.lms.chat.service;

import app.lms.chat.dto.MessageResponse;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.chat.model.Conversation;
import app.lms.user.model.User;
import com.pusher.rest.Pusher;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Map;

@Service
@RequiredArgsConstructor
public class PusherService {

    private final Pusher pusher;
    private final ConversationAccessService conversationAccessService;

    public void publishMessage(
            Conversation conversation,
            MessageResponse message
    ) {

        pusher.trigger(
                channelName(conversation),
                "message.created",
                message
        );
    }

    public void publishMessageDeleted(
            Conversation conversation,
            Long messageId
    ) {

        pusher.trigger(
                channelName(conversation),
                "message.deleted",
                Map.of(
                        "messageId",
                        messageId
                )
        );
    }

    public void publishMessageUpdated(
            Conversation conversation,
            MessageResponse message
    ) {

        pusher.trigger(
                channelName(conversation),
                "message.updated",
                message
        );
    }

    public void publishMute(
            Conversation conversation,
            Long userId,
            String mutedUntil,
            String reason
    ) {

        pusher.trigger(
                channelName(conversation),
                "member.muted",
                Map.of(
                        "userId", userId,
                        "mutedUntil", mutedUntil,
                        "reason", reason == null ? "" : reason
                )
        );
    }

    public void publishUnmute(
            Conversation conversation,
            Long userId
    ) {

        pusher.trigger(
                channelName(conversation),
                "member.unmuted",
                Map.of(
                        "userId",
                        userId
                )
        );
    }

    public String channelName(
            Conversation conversation
    ) {

        return "private-conversation-"
                + conversation.getId();
    }

    public String authenticate(
            String socketId,
            String channelName,
            User user
    ) {

        String prefix =
                "private-conversation-";

        if (channelName == null
                || !channelName.startsWith(prefix)) {

            throw new ChatAccessDeniedException(
                    "Invalid channel"
            );
        }

        Long conversationId;

        try {

            conversationId =
                    Long.valueOf(
                            channelName.substring(
                                    prefix.length()
                            )
                    );

        } catch (NumberFormatException exception) {

            throw new ChatAccessDeniedException(
                    "Invalid channel"
            );
        }

        Conversation conversation =
                conversationAccessService
                        .getAccessible(
                                conversationId,
                                user
                        );

        if (!channelName(conversation)
                .equals(channelName)) {

            throw new ChatAccessDeniedException(
                    "Invalid channel"
            );
        }

        return pusher.authenticate(
                socketId,
                channelName
        ).toString();
    }

    public void publishMessageRead(
            Conversation conversation,
            Long userId,
            Long messageId
    ) {

        pusher.trigger(
                channelName(conversation),
                "message.read",
                Map.of(
                        "userId", userId,
                        "messageId", messageId
                )
        );
    }
}