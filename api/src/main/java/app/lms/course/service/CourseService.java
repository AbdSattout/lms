package app.lms.course.service;

import app.lms.course.dto.CourseResponse;
import app.lms.course.dto.CreateCourseRequest;
import app.lms.course.mapper.CourseMapper;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.service.MediaService;
import app.lms.organization.emums.Role;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;

    private final OrganizationRepository
            organizationRepository;

    private final OrganizationMemberRepository
            memberRepository;

    private final MediaService mediaService;

    private final CourseMapper courseMapper;

    @Transactional
    public CourseResponse create(

            String name,
            CreateCourseRequest request,
            MultipartFile cover,
            User user
    ) {

        Organization organization =
                organizationRepository.findByName(name)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Organization not found"
                                )
                        );

        OrganizationMember member =
                memberRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                user.getId()
                        )
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "You are not a member"
                                )
                        );

        boolean allowed =
                member.getRole()
                        == Role.OWNER
                        ||
                        member.getRole()
                                == Role.ADMIN;

        if (!allowed) {

            throw new IllegalStateException(
                    "You are not allowed"
            );
        }

        String coverUrl = null;
        String coverFileId = null;

        if (cover != null && !cover.isEmpty()) {

            UploadedFile uploaded =
                    mediaService.upload(
                            cover,
                            "/courses",
                            FileType.IMAGE
                    );

            coverUrl = uploaded.url();
            coverFileId = uploaded.fileId();
        }

        Course course =
                Course.builder()
                        .title(request.getTitle())
                        .description(
                                request.getDescription()
                        )
                        .coverUrl(coverUrl)
                        .coverFileId(coverFileId)
                        .organization(organization)
                        .build();

        courseRepository.save(course);

        return courseMapper.toResponse(course);
    }
}
