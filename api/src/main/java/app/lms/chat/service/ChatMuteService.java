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
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ChatMuteService {

    private final ChatMuteRepository chatMuteRepository;

    private final UserRepository userRepository;

    private final CourseRepository courseRepository;

    private final ConversationRepository conversationRepository;

    private final MuteMapper muteMapper;

    private final OrganizationAccessService organizationAccessService;

    private final CourseAccessService courseAccessService;

    private final PusherService pusherService;


    @Transactional
    public MuteResponse mute(
            MuteUserRequest request,
            User instructor
    ) {

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
                saved.getMutedUntil().toString()
        );


        return muteMapper.toResponse(saved);
    }

    public void validateCanSendMessage(
            User user,
            Conversation conversation
    ) {

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
                                mute.getMutedUntil()
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
                            mute.getMutedUntil()
                    );
                });
    }

    @Transactional
    public void unmute(
            Long muteId,
            User currentUser
    ) {

        ChatMute mute =
                chatMuteRepository
                        .findById(muteId)
                        .orElseThrow(() ->
                                new IllegalArgumentException(
                                        "Mute not found"
                                )
                        );

        if (!mute.getCourse()
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

        organizationAccessService
                .getManageableOrganization(
                        course.getOrganization().getSlug(),
                        user
                );


        courseAccessService
                .getEditableCourse(
                        course.getId(),
                        user
                );
    }
}