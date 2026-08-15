package app.lms.chat.model;

import app.lms.chat.enums.ConversationType;
import app.lms.common.model.BaseEntity;
import app.lms.course.model.Course;
import app.lms.user.model.User;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(
        name = "conversations",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_direct_users",
                        columnNames = {
                                "direct_user_one_id",
                                "direct_user_two_id"
                        }
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
public class Conversation extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(
            nullable = false
    )
    private ConversationType type;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "course_id",
            unique = true
    )
    private Course course;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "direct_user_one_id")
    private User directUserOne;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "direct_user_two_id")
    private User directUserTwo;

    @Column(length = 500)
    private String lastMessagePreview;

    @Column(columnDefinition = "timestamp(6) with time zone")
    private Instant lastMessageAt;
}
