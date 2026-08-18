package app.lms.chat.service;

import app.lms.chat.dto.MuteResponse;
import app.lms.chat.dto.MuteUserRequest;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.chat.exception.ChatMutedException;
import app.lms.chat.mapper.MuteMapper;
import app.lms.chat.model.ChatMute;
import app.lms.chat.model.Conversation;
import app.lms.chat.repository.ChatMuteRepository;
import app.lms.chat.repository.ConversationRepository;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.course.service.CourseAccessService;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatMuteService {

    private final ChatMuteRepository chatMuteRepository;

    private final UserRepository userRepository;

    private final CourseRepository courseRepository;

    private final ConversationRepository conversationRepository;

    private final MuteMapper muteMapper;

    private final CourseAccessService courseAccessService;

    private final PusherService pusherService;

    private final ConversationAccessService conversationAccessService;


    @Transactional
    public MuteResponse mute(
            MuteUserRequest request,
            User instructor
    ) {

        validateAuthenticated(
                instructor
        );

        User user =
                userRepository
                        .findById(request.userId())
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "User not found"
                                )
                        );

        Course course =
                courseRepository
                        .findById(request.courseId())
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Course not found"
                                )
                        );

        Conversation conversation =
                conversationRepository
                        .findById(request.conversationId())
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Conversation not found"
                                )
                        );

        validateMutePermission(
                instructor,
                course
        );

        if (conversation.getCourse() == null
                || !conversation.getCourse()
                .getId()
                .equals(course.getId())) {

            throw new ChatAccessDeniedException(
                    "Conversation does not belong to this course"
            );
        }

        chatMuteRepository
                .findActiveMuteForCourse(
                        user.getId(),
                        course.getId(),
                        LocalDateTime.now()
                )
                .ifPresent(existing -> {
                    throw new IllegalStateException(
                            "User is already muted"
                    );
                });


        if (user.getId()
                .equals(instructor.getId())) {

            throw new IllegalArgumentException(
                    "You cannot mute yourself"
            );
        }

        ChatMute mute =
                new ChatMute();

        mute.setUser(user);
        mute.setCourse(course);
        mute.setConversation(conversation);
        mute.setCreatedBy(instructor);

        mute.setMutedUntil(
                LocalDateTime.now()
                        .plusMinutes(
                                request.durationMinutes()
                        )
        );

        mute.setReason(
                request.reason()
        );

        ChatMute saved =
                chatMuteRepository.save(mute);

        pusherService.publishMute(
                conversation,
                user.getId(),
                saved.getMutedUntil().toString(),
                saved.getReason()
        );


        return muteMapper.toResponse(saved);
    }

    public void validateCanSendMessage(
            User user,
            Conversation conversation
    ) {

        validateAuthenticated(
                user
        );

        if (conversation == null) {

            throw new ChatAccessDeniedException(
                    "Conversation not found"
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        if (conversation.getCourse() != null) {

            chatMuteRepository
                    .findActiveCourseMute(
                            user.getId(),
                            conversation
                                    .getCourse()
                                    .getId(),
                            now
                    )
                    .ifPresent(mute -> {
                        throw new ChatMutedException(
                                "You are muted in this course",
                                mute.getMutedUntil(),
                                mute.getReason()
                        );
                    });
        }

        chatMuteRepository
                .findActiveConversationMute(
                        user.getId(),
                        conversation.getId(),
                        now
                )
                .ifPresent(mute -> {
                    throw new ChatMutedException(
                            "You are muted in this conversation",
                            mute.getMutedUntil(),
                            mute.getReason()
                    );
                });
    }

    @Transactional(readOnly = true)
    public List<MuteResponse> listActiveMutes(
            Long conversationId,
            User user
    ) {

        validateAuthenticated(
                user
        );

        Conversation conversation =
                conversationAccessService.getAccessible(
                        conversationId,
                        user
                );

        return chatMuteRepository
                .findActiveMutesByConversation(
                        conversation.getId(),
                        LocalDateTime.now()
                )
                .stream()
                .map(muteMapper::toResponse)
                .toList();
    }

    @Transactional
    public void unmute(
            Long muteId,
            User currentUser
    ) {

        validateAuthenticated(
                currentUser
        );

        ChatMute mute =
                chatMuteRepository
                        .findById(muteId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Mute not found"
                                )
                        );

        if (mute.getCourse() == null
                || mute.getConversation() == null
                || mute.getConversation().getCourse() == null
                || !mute.getCourse()
                .getId()
                .equals(
                        mute.getConversation()
                                .getCourse()
                                .getId()
                )) {

            throw new ChatAccessDeniedException(
                    "Invalid mute"
            );
        }

        validateMutePermission(
                currentUser,
                mute.getCourse()
        );

        mute.setRevokedAt(
                LocalDateTime.now()
        );

        pusherService.publishUnmute(
                mute.getConversation(),
                mute.getUser().getId()
        );
    }

    private void validateMutePermission(
            User user,
            Course course
    ) {

        courseAccessService
                .getManageableCourse(
                        course.getId(),
                        user
                );
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
