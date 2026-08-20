package app.lms.chat.service;

import app.lms.chat.dto.EditMessageRequest;
import app.lms.chat.dto.MessageResponse;
import app.lms.chat.dto.SendMessageRequest;
import app.lms.chat.enums.ConversationType;
import app.lms.chat.enums.MessageType;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.chat.mapper.MessageMapper;
import app.lms.chat.model.Conversation;
import app.lms.chat.model.ConversationMember;
import app.lms.chat.model.Message;
import app.lms.chat.repository.ConversationMemberRepository;
import app.lms.chat.repository.MessageRepository;
import app.lms.friend.service.FriendService;
import app.lms.organization.service.OrganizationMemberAccessService;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final MessageRepository messageRepository;

    private final ConversationAccessService conversationAccessService;

    private final ChatMuteService chatMuteService;

    private final PusherService pusherService;

    private final MessageMapper messageMapper;

    private final ConversationMemberRepository memberRepository;

    private final OrganizationMemberAccessService organizationMemberAccessService;

    private final FriendService friendService;

    @Transactional
    public MessageResponse sendMessage(
            Long conversationId,
            SendMessageRequest request,
            User user
    ) {

        Conversation conversation =
                conversationAccessService
                        .getAccessible(
                                conversationId,
                                user
                        );

        if (conversation.getType() == ConversationType.DIRECT) {

            friendService.validateIsFriends(
                    conversation.getDirectUserOne().getId(),
                    conversation.getDirectUserTwo().getId()
            );
        }

        chatMuteService.validateCanSendMessage(
                user,
                conversation
        );

        Message message =
                new Message();

        message.setConversation(conversation);
        message.setSender(user);
        message.setContent(request.content().trim());
        message.setType(MessageType.TEXT);

        Message saved =
                messageRepository.save(message);

        conversation.setLastMessagePreview(
                saved.getContent()
        );

        conversation.setLastMessageAt(
                saved.getCreatedAt()
        );

        MessageResponse response =
                messageMapper.toResponse(saved);

        pusherService.publishMessage(
                conversation,
                response
        );

        return response;
    }

    @Transactional(readOnly = true)
    public Page<MessageResponse> getMessages(
            Long conversationId,
            User user,
            Pageable pageable
    ) {

        conversationAccessService
                .getAccessible(
                        conversationId,
                        user
                );

        return messageRepository
                .findAllByConversationIdOrderByCreatedAtDesc(
                        conversationId,
                        pageable
                )
                .map(messageMapper::toResponse);
    }

    @Transactional
    public MessageResponse editMessage(
            Long conversationId,
            Long messageId,
            EditMessageRequest request,
            User user
    ) {

        Conversation conversation =
                conversationAccessService
                        .getAccessible(
                                conversationId,
                                user
                        );

        Message message =
                messageRepository
                        .findByIdAndConversationId(
                                messageId,
                                conversationId
                        )
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Message not found"
                                )
                        );

        if (!message.getSender()
                .getId()
                .equals(user.getId())) {

            throw new ChatAccessDeniedException(
                    "You can only edit your own messages"
            );
        }

        if (message.getDeletedAt() != null) {

            throw new IllegalStateException(
                    "Deleted message cannot be edited"
            );
        }

        message.setContent(
                request.content().trim()
        );

        message.setEditedAt(
                LocalDateTime.now()
        );

        MessageResponse response =
                messageMapper.toResponse(message);

        pusherService.publishMessageUpdated(
                conversation,
                response
        );

        return response;
    }

    @Transactional
    public void deleteMessage(
            Long conversationId,
            Long messageId,
            User user
    ) {

        Conversation conversation =
                conversationAccessService
                        .getAccessible(
                                conversationId,
                                user
                        );

        Message message =
                messageRepository
                        .findByIdAndConversationId(
                                messageId,
                                conversationId
                        )
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Message not found"
                                )
                        );

        boolean isSender =
                message.getSender()
                        .getId()
                        .equals(user.getId());

        boolean isManager =
                !isSender
                        && conversation.getCourse() != null
                        && conversation.getCourse().getOrganization() != null
                        && organizationMemberAccessService.isManager(
                                conversation
                                        .getCourse()
                                        .getOrganization()
                                        .getId(),
                                user.getId()
                        );

        if (!isSender
                && !isManager) {

            throw new ChatAccessDeniedException(
                    "You can only delete your own messages"
            );
        }

        if (message.getDeletedAt() != null) {

            throw new IllegalStateException(
                    "Message already deleted"
            );
        }

        message.setDeletedAt(
                LocalDateTime.now()
        );

        pusherService.publishMessageDeleted(
                conversation,
                messageId
        );
    }

    @Transactional
    public void markAsRead(
            Long conversationId,
            Long messageId,
            User user
    ) {

        Conversation conversation =
                conversationAccessService
                        .getAccessible(
                                conversationId,
                                user
                        );

        Message message =
                messageRepository
                        .findByIdAndConversationId(
                                messageId,
                                conversationId
                        )
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Message not found"
                                )
                        );

        ConversationMember member =
                getOrCreateMember(
                        conversation,
                        user
                );

        member.setLastReadMessageId(
                message.getId()
        );

        member.setLastReadAt(
                LocalDateTime.now()
        );

        pusherService.publishMessageRead(
                conversation,
                user.getId(),
                message.getId()
        );
    }

    private ConversationMember getOrCreateMember(
            Conversation conversation,
            User user
    ) {

        return memberRepository
                .findByConversationIdAndUserId(
                        conversation.getId(),
                        user.getId()
                )
                .orElseGet(() -> {

                    ConversationMember member =
                            new ConversationMember();

                    member.setConversation(
                            conversation
                    );

                    member.setUser(user);

                    member.setJoinedAt(
                            LocalDateTime.now()
                    );

                    return memberRepository.save(
                            member
                    );
                });
    }
}