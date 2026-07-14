package app.lms.media.model;

import app.lms.common.model.BaseEntity;
import app.lms.media.enums.FileType;
import app.lms.organization.model.Organization;
import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(
        name = "organization_media",
        uniqueConstraints = {
                @UniqueConstraint(
                        name = "uk_organization_media_organization_name",
                        columnNames = {"organization_id", "name"}
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrganizationMedia extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String url;

    @Column(nullable = false)
    private String fileId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private FileType type;

    @Column(nullable = false)
    private Long sizeBytes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(
            name = "organization_id",
            nullable = false
    )
    private Organization organization;

    @OneToMany(mappedBy = "organizationMedia")
    @Builder.Default
    private List<CourseMedia> courseMedia = new ArrayList<>();

    @OneToMany(mappedBy = "organizationMedia")
    @Builder.Default
    private List<PostMedia> postMedia = new ArrayList<>();
}
