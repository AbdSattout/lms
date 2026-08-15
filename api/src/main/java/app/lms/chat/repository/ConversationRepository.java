package app.lms.chat.repository;

import app.lms.chat.enums.ConversationType;
import app.lms.chat.model.Conversation;
import app.lms.enrollment.enums.EnrollmentStatus;
import app.lms.organization.enums.Role;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Collection;
import java.util.Optional;

public interface ConversationRepository
        extends JpaRepository<Conversation, Long> {

    Optional<Conversation> findByCourseId(Long courseId);

    Optional<Conversation>
    findByTypeAndDirectUserOneIdAndDirectUserTwoId(
            ConversationType type,
            Long directUserOneId,
            Long directUserTwoId
    );

    @Query(
            value = """
                    select conversation
                    from Conversation conversation
                    left join fetch conversation.course course
                    left join fetch conversation.directUserOne
                    left join fetch conversation.directUserTwo
                    where (
                        conversation.type = :directType
                        and exists (
                            select member.id
                            from ConversationMember member
                            where member.conversation.id = conversation.id
                            and member.user.id = :userId
                        )
                    )
                    or (
                        conversation.type = :courseType
                        and conversation.course is not null
                        and (
                            exists (
                                select enrollment.id
                                from CourseEnrollment enrollment
                                where enrollment.course.id = course.id
                                and enrollment.user.id = :userId
                                and enrollment.status = :activeEnrollmentStatus
                            )
                            or exists (
                                select organizationMember.id
                                from OrganizationMember organizationMember
                                where organizationMember.organization.id = course.organization.id
                                and organizationMember.user.id = :userId
                                and organizationMember.role in :managerRoles
                            )
                        )
                        and not exists (
                            select moderation.id
                            from OrganizationModeration moderation
                            where moderation.organization.id = course.organization.id
                            and (
                                moderation.expiresAt is null
                                or moderation.expiresAt > CURRENT_TIMESTAMP
                            )
                        )
                        and not exists (
                            select ban.id
                            from OrganizationBan ban
                            where ban.organization.id = course.organization.id
                            and ban.user.id = :userId
                            and (
                                ban.expiresAt is null
                                or ban.expiresAt > CURRENT_TIMESTAMP
                            )
                        )
                    )
                    order by coalesce(conversation.lastMessageAt, conversation.createdAt) desc
                    """,
            countQuery = """
                    select count(conversation)
                    from Conversation conversation
                    left join conversation.course course
                    where (
                        conversation.type = :directType
                        and exists (
                            select member.id
                            from ConversationMember member
                            where member.conversation.id = conversation.id
                            and member.user.id = :userId
                        )
                    )
                    or (
                        conversation.type = :courseType
                        and conversation.course is not null
                        and (
                            exists (
                                select enrollment.id
                                from CourseEnrollment enrollment
                                where enrollment.course.id = course.id
                                and enrollment.user.id = :userId
                                and enrollment.status = :activeEnrollmentStatus
                            )
                            or exists (
                                select organizationMember.id
                                from OrganizationMember organizationMember
                                where organizationMember.organization.id = course.organization.id
                                and organizationMember.user.id = :userId
                                and organizationMember.role in :managerRoles
                            )
                        )
                        and not exists (
                            select moderation.id
                            from OrganizationModeration moderation
                            where moderation.organization.id = course.organization.id
                            and (
                                moderation.expiresAt is null
                                or moderation.expiresAt > CURRENT_TIMESTAMP
                            )
                        )
                        and not exists (
                            select ban.id
                            from OrganizationBan ban
                            where ban.organization.id = course.organization.id
                            and ban.user.id = :userId
                            and (
                                ban.expiresAt is null
                                or ban.expiresAt > CURRENT_TIMESTAMP
                            )
                        )
                    )
                    """
    )
    Page<Conversation> findAccessibleByUserId(
            @Param("userId") Long userId,
            @Param("directType") ConversationType directType,
            @Param("courseType") ConversationType courseType,
            @Param("activeEnrollmentStatus") EnrollmentStatus activeEnrollmentStatus,
            @Param("managerRoles") Collection<Role> managerRoles,
            Pageable pageable
    );
}
