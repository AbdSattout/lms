package app.lms.course.model;

import app.lms.organization.model.BaseEntity;
import app.lms.organization.model.Organization;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "courses")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Course extends BaseEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String title;

    private String coverUrl;

    private String coverFileId;


    @Lob
    @Column
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "organization_id",nullable = true)
    private Organization organization;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;


}
