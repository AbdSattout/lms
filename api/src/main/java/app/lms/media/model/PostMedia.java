package app.lms.media.model;

import app.lms.common.model.BaseEntity;
import app.lms.media.enums.FileType;
import app.lms.organization.model.Organization;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(
        name = "post_media",
        uniqueConstraints = {
                @UniqueConstraint(
                        columnNames = {"post_id", "name"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PostMedia extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String name;

    @Column(columnDefinition = "TEXT")
    private String url;

    private String fileId;

    @Enumerated(EnumType.STRING)
    private FileType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "Organization_id" , nullable = false)
    private Organization organization;
}
