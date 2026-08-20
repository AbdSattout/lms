package app.lms.chat.service;


import app.lms.chat.dto.ConversationResponse;
import app.lms.chat.enums.ConversationType;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.chat.mapper.ConversationMapper;
import app.lms.chat.model.Conversation;
import app.lms.chat.model.ConversationMember;
import app.lms.chat.repository.ConversationMemberRepository;
import app.lms.chat.repository.ConversationRepository;
import app.lms.course.model.Course;
import app.lms.course.service.CourseAccessService;
import app.lms.friend.service.FriendService;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ConversationService {

    private final ConversationRepository
            conversationRepository;

    private final ConversationMemberRepository
            memberRepository;

    private final UserRepository userRepository;

    private final ConversationMapper conversationMapper;

    private final FriendService friendService;

    private final CourseAccessService courseAccessService;

    @Transactional
    public Conversation getOrCreateDirectConversation(
            User currentUser,
            User targetUser
    ) {

        validateAuthenticated(
                currentUser
        );

        Long userOneId = Math.min(
                currentUser.getId(),
                targetUser.getId()
        );

        Long userTwoId = Math.max(
                currentUser.getId(),
                targetUser.getId()
        );

        return conversationRepository
                .findByTypeAndDirectUserOneIdAndDirectUserTwoId(
                        ConversationType.DIRECT,
                        userOneId,
                        userTwoId
                )
                .orElseGet(() -> {
                    if (currentUser.getId()
                            .equals(targetUser.getId())) {

                        throw new IllegalArgumentException(
                                "You cannot chat with yourself"
                        );
                    }

                    friendService.validateIsFriends(
                            userOneId,
                            userTwoId
                    );

                    return createDirectConversation(
                            currentUser,
                            targetUser
                    );
                });
    }

    private Conversation createDirectConversation(
            User currentUser,
            User targetUser
    ) {

        Conversation conversation =
                new Conversation();

        conversation.setType(
                ConversationType.DIRECT
        );

        if (currentUser.getId()
                < targetUser.getId()) {

            conversation.setDirectUserOne(
                    currentUser
            );

            conversation.setDirectUserTwo(
                    targetUser
            );

        } else {

            conversation.setDirectUserOne(
                    targetUser
            );

            conversation.setDirectUserTwo(
                    currentUser
            );
        }

        Conversation saved =
                conversationRepository.save(
                        conversation
                );

        createMember(
                saved,
                currentUser
        );

        createMember(
                saved,
                targetUser
        );

        return saved;
    }

    private void createMember(
            Conversation conversation,
            User user
    ) {

        ConversationMember member =
                new ConversationMember();

        member.setConversation(
                conversation
        );

        member.setUser(user);

        member.setJoinedAt(
                LocalDateTime.now()
        );

        memberRepository.save(member);
    }

    @Transactional
    public ConversationResponse directConversation(Long userId, User currentUser) {

        validateAuthenticated(
                currentUser
        );

        User targetUser =
                userRepository
                        .findById(userId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "User not found"
                                )
                        );

        Conversation conversation =
                getOrCreateDirectConversation(
                        currentUser,
                        targetUser
                );

        return conversationMapper
                .toResponse(conversation);

    }

    @Transactional(readOnly = true)
    public Page<ConversationResponse> listConversations(
            Pageable pageable,
            User currentUser
    ) {

        validateAuthenticated(
                currentUser
        );

        return conversationRepository
                .findDirectByUserId(
                        currentUser.getId(),
                        ConversationType.DIRECT,
                        pageable
                )
                .map(conversationMapper::toResponse);
    }

    @Transactional
    public ConversationResponse courseConversation(
            Long courseId,
            User currentUser
    ) {

        validateAuthenticated(
                currentUser
        );

        Course course =
                courseAccessService.getEnrolledCourse(
                        courseId,
                        currentUser
                );

        Conversation conversation =
                getOrCreateCourseConversation(
                        course
                );

        return conversationMapper.toResponse(
                conversation
        );
    }

    @Transactional
    public Conversation getOrCreateCourseConversation(
            Course course
    ) {

        return conversationRepository
                .findByCourseId(course.getId())
                .orElseGet(() -> {

                    Conversation conversation =
                            new Conversation();

                    conversation.setType(
                            ConversationType.COURSE
                    );

                    conversation.setCourse(course);

                    return conversationRepository.save(
                            conversation
                    );
                });
    }

    private void validateAuthenticated(
            User user
    ) {

        if (user == null
                || user.getId() == null) {
            throw new ChatAccessDeniedException(
                    "Authentication required"
            );
        }
    }

}
