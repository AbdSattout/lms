package app.lms.organization.service;

import app.lms.common.exception.ConflictException;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.organization.emums.Role;
import app.lms.organization.emums.Visibility;
import app.lms.media.service.MediaService;
import app.lms.organization.dto.CreateOrganizationRequest;
import app.lms.organization.dto.OrganizationResponse;
import app.lms.organization.dto.UpdateOrganizationRequest;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.user.model.User;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class OrganizationService {

    private static final Logger log =
            LoggerFactory.getLogger(
                    OrganizationService.class
            );
    private final OrganizationRepository organizationRepository;
    private final OrganizationMemberRepository memberRepository;
    private final MediaService mediaService;
    private final OrganizationMapper organizationMapper;
    private final CourseRepository courseRepository;
    private final OrganizationAccessService organizationAccessService;

    @Transactional
    public OrganizationResponse create(
            CreateOrganizationRequest request,
            MultipartFile image,
            User user
    ) {
        String name =
                request.getName().trim();

        if (organizationRepository.existsByNameIgnoreCase(name)) {
            throw new ConflictException(
                    "Organization name already exists"
            );
        }

        String slug =
                request.getSlug()
                        .trim()
                        .toLowerCase();
        if (organizationRepository.existsBySlug(slug)) {
            throw new ConflictException(
                    "Slug already exists"
            );
        }

        UploadedFile uploaded =
                hasImage(image)
                        ? uploadOrganizationImage(image)
                        : null;

        Organization organization = Organization.builder()
                .name(name)
                .slug(slug)
                .description(request.getDescription()!=null? request.getDescription().trim():null)
                .imageUrl(
                        uploaded != null
                                ? uploaded.url()
                                : null
                )
                .imageFileId(
                        uploaded != null
                                ? uploaded.fileId()
                                : null
                )
                .visibility(
                        request.getVisibility() == null
                                ? Visibility.PUBLIC
                                : request.getVisibility()
                )
                .owner(user)
                .build();

        organizationRepository.save(organization);

        createOwnerMember(
                organization,
                user
        );

        return organizationMapper.ToResponse(
                organization
        );
    }

    public OrganizationResponse getBySlug(String slug) {

        Organization organization =
                organizationAccessService.getBySlug(slug);

        return organizationMapper.ToResponse(
                organization
        );
    }

    public List<OrganizationResponse> getAll() {

        return organizationRepository.findAll()
                .stream()
                .map(organizationMapper::ToResponse)
                .toList();
    }

    @Transactional
    public OrganizationResponse update(
            String slug,
            UpdateOrganizationRequest request,
            MultipartFile image,
            User user
    ) {

        Organization organization =
                organizationAccessService.getOwnedOrganization(
                        slug,
                        user
                );

        if (request.getName() != null) {
            updateOrganizationName(
                    organization,
                    request.getName().trim()
            );
        }

        if (hasImage(image)) {

            String oldFileId =
                    organization.getImageFileId();

            UploadedFile uploaded =
                    uploadOrganizationImage(
                            image
                    );

            organization.setImageUrl(
                    uploaded.url()
            );

            organization.setImageFileId(
                    uploaded.fileId()
            );

            if (oldFileId != null) {
                try {
                    mediaService.delete(oldFileId);
                } catch (ImageDeleteException ex) {
                    log.error(
                            "Failed to delete organization image {}",
                            oldFileId,
                            ex
                    );
                }
            }
        }

        if (request.getSlug() != null) {
            updateOrganizationSlug(
                    organization,
                    request.getSlug()
                            .trim()
                            .toLowerCase()
            );
        }
        if (request.getDescription() != null) {
            organization.setDescription(
                    request.getDescription().trim()
            );
        }

        if (request.getVisibility() != null) {
            organization.setVisibility(
                    request.getVisibility()
            );
        }

        return organizationMapper.ToResponse(
                organization
        );
    }

    private void updateOrganizationSlug(
            Organization organization,
            String newSlug
    ) {

        if (
                !newSlug.equals(
                        organization.getSlug()
                )
                        &&
                        organizationRepository.existsBySlug(
                                newSlug
                        )
        ) {

            throw new ConflictException(
                    "Slug already exists"
            );
        }

        organization.setSlug(
                newSlug
        );
    }
    private void updateOrganizationName(
            Organization organization,
            String newName
    ) {

        newName = newName.trim();

        if (
                !newName.equalsIgnoreCase(
                        organization.getName()
                )
                        &&
                        organizationRepository.existsByNameIgnoreCase(
                                newName
                        )
        ) {

            throw new ConflictException(
                    "Organization name already exists"
            );
        }

        organization.setName(newName);
    }
    @Transactional
    public void delete(
            String slug,
            User user
    ) {

        Organization organization =

                organizationAccessService.getOwnedOrganization(
                        slug,
                        user
                );

        memberRepository.deleteByOrganizationId(
                organization.getId()
        );

        List<Course> courses =
                courseRepository.findAllByOrganizationId(
                        organization.getId()
                );

        courses.stream()
                .map(Course::getCoverFileId)
                .filter(Objects::nonNull)
                .forEach(fileId -> {
                    try {
                        mediaService.delete(fileId);
                    }catch (ImageDeleteException ex) {
                        log.error(
                                "Failed to delete course cover {}",
                                fileId,
                                ex
                        );
                    }
                });

        courseRepository.deleteAll(
                courses
        );

        if (organization.getImageFileId() != null) {
            try {
                mediaService.delete(
                        organization.getImageFileId()
                );
            } catch (ImageDeleteException ex) {
                log.error(
                        "Failed to delete organization image {}",
                        organization.getImageFileId(),
                        ex
                );
            }
        }

        organizationRepository.delete(
                organization
        );
    }


    private boolean hasImage(MultipartFile image) {
        return image != null && !image.isEmpty();
    }
    private UploadedFile uploadOrganizationImage(
            MultipartFile image
    ) {

        return mediaService.upload(
                image,
                "/organizations",
                FileType.IMAGE
        );
    }
    private void createOwnerMember(
            Organization organization,
            User user
    ) {

        memberRepository.save(
                OrganizationMember.builder()
                        .organization(organization)
                        .user(user)
                        .role(Role.OWNER)
                        .build()
        );
    }


}
