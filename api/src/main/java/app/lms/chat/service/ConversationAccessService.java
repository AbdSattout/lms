package app.lms.chat.service;

import app.lms.chat.enums.ConversationType;
import app.lms.chat.exception.ChatAccessDeniedException;
import app.lms.chat.model.Conversation;
import app.lms.chat.repository.ConversationMemberRepository;
import app.lms.chat.repository.ConversationRepository;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.enrollment.repository.CourseEnrollmentRepository;
import app.lms.user.model.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ConversationAccessService {

    private final ConversationRepository conversationRepository;

    private final ConversationMemberRepository memberRepository;

    private final CourseEnrollmentRepository enrollmentRepository;


    public Conversation getById(
            Long conversationId
    ) {

        return conversationRepository
                .findById(conversationId)
                .orElseThrow(() ->
                        new ChatAccessDeniedException(
                                "Conversation not found"
                        )
                );
    }

    public Conversation getAccessible(
            Long conversationId,
            User user
    ) {

        Conversation conversation =
                conversationRepository
                        .findById(conversationId)
                        .orElseThrow(() ->
                                new ChatAccessDeniedException(
                                        "Conversation not found"
                                )
                        );

        if (conversation.getType()
                == ConversationType.DIRECT) {

            validateDirectAccess(
                    conversation,
                    user
            );

        } else if (conversation.getType()
                == ConversationType.COURSE) {

            validateCourseAccess(
                    conversation,
                    user
            );
        }

        return conversation;
    }

    private void validateDirectAccess(
            Conversation conversation,
            User user
    ) {

        boolean member =
                memberRepository
                        .existsByConversationIdAndUserId(
                                conversation.getId(),
                                user.getId()
                        );

        if (!member) {

            throw new ChatAccessDeniedException(
                    "You are not a member of this conversation"
            );
        }
    }

    private void validateCourseAccess(
            Conversation conversation,
            User user
    ) {

        Long courseId =
                conversation
                        .getCourse()
                        .getId();

        boolean enrolled =
                enrollmentRepository
                        .existsByCourseIdAndUserIdAndStatus(
                                courseId,
                                user.getId(),
                                EnrollmentStatus.ACTIVE
                        );

        if (!enrolled) {

            throw new ChatAccessDeniedException(
                    "You are not enrolled in this course"
            );
        }
    }
}