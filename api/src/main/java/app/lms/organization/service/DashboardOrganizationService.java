package app.lms.organization.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.service.MediaService;
import app.lms.organization.dto.*;
import app.lms.organization.enums.InviteStatus;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationInvite;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.repository.OrganizationInviteRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DashboardOrganizationService {

    private final OrganizationRepository organizationRepository;
    private final MediaService mediaService;
    private final OrganizationMapper organizationMapper;
    private final OrganizationMemberRepository organizationMemberRepository;
    private final OrganizationAccessService organizationAccessService;
    private final CourseRepository courseRepository;
    private final OrganizationInviteRepository organizationInviteRepository;
    private final UserRepository userRepository;

    private static final Logger log =
            LoggerFactory.getLogger(
                    DashboardOrganizationService.class
    );

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
              image != null && !image.isEmpty()
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


    @Transactional
    public OrganizationResponse update(
            String slug,
            UpdateOrganizationRequest request,
            MultipartFile image,
            User user
    ) {

        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        user
                );

        if (request.getName() != null) {
            updateOrganizationName(
                    organization,
                    request.getName().trim()
            );
        }

        if (image != null && !image.isEmpty()) {

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


    @Transactional
    public void delete(
            String slug,
            User user
    ) {

        Organization organization =

                organizationAccessService.getManageableOrganization(
                        slug,
                        user
                );

        organizationMemberRepository.deleteByOrganizationId(
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

        organizationMemberRepository.save(
                OrganizationMember.builder()
                        .organization(organization)
                        .user(user)
                        .role(Role.OWNER)
                        .build()
        );
    }

    public boolean isSlugAvailable(String slug) {
        return !organizationRepository.existsBySlug(slug);
    }

    public OrganizationResponse
    getDashboardOrganization(
            String slug,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        return organizationMapper
                .ToResponse(
                        organization
                );
    }
    public List<OrganizationResponse>
    getDashboardOrganizations(
            User user
    ) {

        return organizationRepository
                .findManagedOrganizations(
                        user.getId()
                )
                .stream()
                .map(
                        organizationMapper::ToResponse
                )
                .toList();
    }

    public Page<OrganizationMemberResponse> getMembers(
            String slug,
            Pageable pageable,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                currentUser
                        );

        return organizationMemberRepository
                .findByOrganizationId(
                        organization.getId(),
                        pageable
                )
                .map(organizationMapper::toMemberResponse);

    }

    public OrganizationInviteResponse invite(
            String slug,
            CreateInviteRequest request,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService.getManageableOrganization(
                        slug,
                        currentUser
                );

        if (organizationInviteRepository.existsByOrganizationIdAndUserIdAndStatus(
                organization.getId(),
                request.getUserId(),
                InviteStatus.PENDING
        )) {

            throw new BadRequestException(
                    "User already invited"
            );
        }
        User targetUser = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new NotFoundException("User not found"));

        OrganizationInvite invite =
                OrganizationInvite.builder()
                        .organization(organization)
                        .user(targetUser)
                        .role(request.getRole() != null ? request.getRole() : Role.STUDENT)
                        .status(InviteStatus.PENDING)
                        .token(UUID.randomUUID().toString())
                        .expiresAt(LocalDateTime.now().plusDays(7))
                        .invitedBy(currentUser)
                        .build();

        OrganizationInvite savedInvite = organizationInviteRepository.save(invite);

        return organizationMapper.toResponse(savedInvite);

    }
    @Transactional
    public OrganizationInviteResponse resendInvite(
            String slug,
            Long inviteId,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationInvite invite = organizationInviteRepository.findById(inviteId)
                .orElseThrow(() -> new NotFoundException("Invite not found"));

        if (!invite.getOrganization().getId().equals(organization.getId())) {
            throw new BadRequestException("Invalid invite");
        }

        if (invite.getStatus() == InviteStatus.ACCEPTED) {
            throw new BadRequestException("User has already accepted the invitation");
        }

        invite.setToken(UUID.randomUUID().toString());
        invite.setExpiresAt(LocalDateTime.now().plusDays(7));
        invite.setStatus(InviteStatus.PENDING);
        invite.setInvitedBy(currentUser);

        OrganizationInvite updatedInvite = organizationInviteRepository.save(invite);

        return organizationMapper.toResponse(updatedInvite);

    }

    public List<OrganizationInviteResponse> getPendingInvites(
            String slug,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        return organizationInviteRepository.findAllByOrganizationIdAndStatus(
                        organization.getId(),
                        InviteStatus.PENDING
                ).stream()
                .map(organizationMapper::toResponse)
                .toList();
    }

    @Transactional
    public OrganizationInviteResponse createPublicInvite(
            String slug,
            CreatePublicInviteRequest request,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationInvite invite = OrganizationInvite.builder()
                .organization(organization)
                .user(null)
                .role(request.getRole() != null ? request.getRole() : Role.STUDENT)
                .status(InviteStatus.PENDING)
                .token(UUID.randomUUID().toString())
                .expiresAt(LocalDateTime.now().plusDays(30))
                .maxUses(request.getMaxUses())
                .usedCount(0)
                .invitedBy(currentUser)
                .build();

        OrganizationInvite savedInvite = organizationInviteRepository.save(invite);
        return organizationMapper.toResponse(savedInvite);
    }
    @Transactional
    public OrganizationInviteResponse updatePublicInviteCapacity(
            String slug,
            Long inviteId,
            UpdateInviteCapacityRequest request,
            User currentUser
    ) {
        Organization organization =
                organizationAccessService.getManageableOrganization(slug, currentUser);

        OrganizationInvite invite = organizationInviteRepository.findById(inviteId)
                .orElseThrow(() -> new NotFoundException("Invite not found"));

        if (!invite.getOrganization().getId().equals(organization.getId())) {
            throw new BadRequestException("Invalid invite");
        }

        if (invite.getUser() != null) {
            throw new BadRequestException("Cannot change capacity for a personal invite");
        }

        if (request.getMaxUses() != null && request.getMaxUses() < invite.getUsedCount()) {
            throw new BadRequestException("Max uses cannot be less than the current used count (" + invite.getUsedCount() + ")");
        }

        invite.setMaxUses(request.getMaxUses());

        if (invite.getStatus() == InviteStatus.EXPIRED &&
                (request.getMaxUses() == null || invite.getUsedCount() < request.getMaxUses())) {
            invite.setStatus(InviteStatus.PENDING);
        }

        OrganizationInvite updatedInvite = organizationInviteRepository.save(invite);
        return organizationMapper.toResponse(updatedInvite);
    }
}
