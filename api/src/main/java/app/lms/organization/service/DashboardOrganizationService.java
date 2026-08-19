package app.lms.organization.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.common.exception.NotFoundException;
import app.lms.moderation.dto.BanRequest;
import app.lms.moderation.service.BanNotificationEmailService;
import app.lms.course.model.Course;
import app.lms.course.repository.CourseRepository;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageDeleteException;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.repository.CourseMediaRepository;
import app.lms.media.repository.OrganizationMediaRepository;
import app.lms.media.repository.PostMediaRepository;
import app.lms.media.service.MediaService;
import app.lms.organization.OrganizationBan.model.OrganizationBan;
import app.lms.organization.OrganizationBan.repository.OrganizationBanRepository;
import app.lms.organization.dto.*;
import app.lms.organization.enums.Role;
import app.lms.organization.enums.Visibility;
import app.lms.organization.mapper.OrganizationMapper;
import app.lms.organization.model.Organization;
import app.lms.organization.model.OrganizationMember;
import app.lms.organization.organizationInvite.enums.InviteStatus;
import app.lms.organization.organizationInvite.model.OrganizationInvite;
import app.lms.organization.organizationInvite.repository.OrganizationInviteRepository;
import app.lms.organization.organizationJoinRequest.repository.OrganizationJoinRequestRepository;
import app.lms.organization.repository.OrganizationMemberRepository;
import app.lms.organization.repository.OrganizationRepository;
import app.lms.plan.service.PlanQuotaService;
import app.lms.post.repository.PostRepository;
import app.lms.roadmap.repository.RoadmapRepository;
import app.lms.user.mapper.UserMapper;
import app.lms.user.model.User;
import app.lms.user.repository.UserRepository;
import app.lms.user.repository.projection.UserSearchRow;
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
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;

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
    private final OrganizationJoinRequestRepository organizationJoinRequestRepository;
    private final OrganizationMediaRepository organizationMediaRepository;
    private final PostMediaRepository postMediaRepository;
    private final CourseMediaRepository courseMediaRepository;
    private final PostRepository postRepository;
    private final RoadmapRepository roadmapRepository;
    private final PlanQuotaService planQuotaService;
    private final OrganizationMemberAccessService organizationMemberAccessService;
    private final OrganizationViewerService organizationViewerService;
    private final OrganizationBanRepository organizationBanRepository;
    private final UserRepository userRepository;
    private final UserMapper userMapper;
    private final BanNotificationEmailService banNotificationEmailService;

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

        planQuotaService.validateOrganizationCreationAllowed(
                user,
                () -> organizationRepository.countByOwnerId(
                        user.getId()
                )
        );

        UploadedFile uploaded =
                image != null && !image.isEmpty()
                        ? uploadOrganizationImage(
                                image,
                                user
                        )
                        : null;

        Organization organization = Organization.builder()
                .name(name)
                .slug(slug)
                .description(request.getDescription() != null ? request.getDescription().trim() : null)
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
                            image,
                            organization.getOwner()
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

        Long organizationId =
                organization.getId();

        organizationInviteRepository.deleteByOrganizationId(
                organizationId
        );

        organizationJoinRequestRepository.deleteByOrganizationId(
                organizationId
        );

        roadmapRepository.deleteByOrganizationId(
                organizationId
        );

        postRepository.deleteByOrganizationId(
                organizationId
        );

        List<OrganizationMedia> organizationMedia =
                organizationMediaRepository.findAllByOrganizationId(
                        organizationId
                );

        organizationMedia.stream()
                .map(OrganizationMedia::getFileId)
                .filter(Objects::nonNull)
                .forEach(fileId -> {
                    try {
                        mediaService.delete(fileId);
                    } catch (ImageDeleteException ex) {
                        log.error(
                                "Failed to delete organization media {}",
                                fileId,
                                ex
                        );
                    }
                });

        postMediaRepository.deleteByOrganizationId(
                organizationId
        );

        courseMediaRepository.deleteByOrganizationMediaOrganizationId(
                organizationId
        );

        organizationMediaRepository.deleteByOrganizationId(
                organizationId
        );

        organizationMemberRepository.deleteByOrganizationId(
                organizationId
        );

        List<Course> courses =
                courseRepository.findAllByOrganizationId(
                        organizationId
                );

        courses.stream()
                .map(Course::getCoverFileId)
                .filter(Objects::nonNull)
                .forEach(fileId -> {
                    try {
                        mediaService.delete(fileId);
                    } catch (ImageDeleteException ex) {
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
            MultipartFile image,
            User planOwner
    ) {

        validateGifUploadAllowed(
                planOwner,
                image
        );

        return mediaService.upload(
                image,
                "/organizations",
                FileType.IMAGE,
                true
        );
    }

    private void validateGifUploadAllowed(
            User planOwner,
            MultipartFile image
    ) {

        if (!mediaService.isGif(image)) {
            return;
        }

        planQuotaService.validateGifUploadAllowed(planOwner);
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
                        organization,
                        organizationViewerService.forOrganization(
                                organization,
                                user
                        )
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
                        organization -> organizationMapper
                                .ToResponse(
                                        organization,
                                        organizationViewerService.forOrganization(
                                                organization,
                                                user
                                        )
                                )
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
                .findActiveByOrganizationId(
                        organization.getId(),
                        pageable
                )
                .map(organizationMapper::toMemberResponse);

    }
    public Page<OrganizationMemberResponse> getMembersByRole(
            String slug,
            Role role,
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
                .findActiveByOrganizationIdAndRole(
                        organization.getId(),
                        role,
                        pageable
                )
                .map(organizationMapper::toMemberResponse);
    }

    public Page<OrganizationBannedUserResponse> getBannedUsers(
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

        return organizationBanRepository
                .findAllActiveByOrganizationId(
                        organization.getId(),
                        pageable
                )
                .map(organizationMapper::toBannedUserResponse);
    }

    public List<OrganizationUserSearchResponse> searchUsers(
            String slug,
            String q,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                currentUser
                        );

        String searchQuery =
                q == null ? "" : q.trim();

        String usernameQ =
                searchQuery;

        if (usernameQ.startsWith("@")) {
            usernameQ =
                    usernameQ.substring(1);
        }

        List<UserSearchRow> rows =
                userRepository
                        .searchWithProfile(
                                searchQuery,
                                usernameQ
                        )
                        .stream()
                        .filter(row ->
                                !row.getUser()
                                        .getId()
                                        .equals(
                                                currentUser.getId()
                                        )
                        )
                        .toList();

        List<Long> userIds =
                rows.stream()
                        .map(row ->
                                row.getUser()
                                        .getId()
                        )
                        .toList();

        Map<Long, OrganizationMember> membersByUserId =
                loadMembersByUserId(
                        organization.getId(),
                        userIds
                );

        Map<Long, OrganizationInvite> invitesByUserId =
                loadPendingInvitesByUserId(
                        organization.getId(),
                        userIds
                );

        return rows.stream()
                .map(row ->
                        toOrganizationUserSearchResponse(
                                row,
                                membersByUserId.get(
                                        row.getUser()
                                                .getId()
                                ),
                                invitesByUserId.get(
                                        row.getUser()
                                                .getId()
                                )
                        )
                )
                .toList();
    }

    private Map<Long, OrganizationMember> loadMembersByUserId(
            Long organizationId,
            List<Long> userIds
    ) {

        if (userIds.isEmpty()) {
            return Map.of();
        }

        return organizationMemberRepository
                .findAllActiveByOrganizationIdAndUserIdIn(
                        organizationId,
                        userIds
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                member ->
                                        member.getUser()
                                                .getId(),
                                Function.identity()
                        )
                );
    }

    private Map<Long, OrganizationInvite> loadPendingInvitesByUserId(
            Long organizationId,
            List<Long> userIds
    ) {

        if (userIds.isEmpty()) {
            return Map.of();
        }

        return organizationInviteRepository
                .findAllByOrganizationIdAndUserIdInAndStatus(
                        organizationId,
                        userIds,
                        InviteStatus.PENDING
                )
                .stream()
                .collect(
                        Collectors.toMap(
                                invite ->
                                        invite.getUser()
                                                .getId(),
                                Function.identity()
                        )
                );
    }

    private OrganizationUserSearchResponse toOrganizationUserSearchResponse(
            UserSearchRow row,
            OrganizationMember member,
            OrganizationInvite invite
    ) {

        return OrganizationUserSearchResponse.builder()
                .name(row.getUser().getName())
                .email(row.getProfile() != null ? row.getProfile().getEmail() : null)
                .phone(row.getProfile() != null ? row.getProfile().getPhone() : null)
                .university(row.getProfile() != null ? row.getProfile().getUniversity() : null)
                .user(userMapper.toResponse(row.getUser()))
                .member(member != null)
                .role(member != null ? member.getRole() : null)
                .invited(invite != null)
                .inviteId(invite != null ? invite.getId() : null)
                .inviteStatus(invite != null ? invite.getStatus() : null)
                .inviteRole(invite != null ? invite.getRole() : null)
                .build();
    }

    @Transactional
    public void removeMember(
            String slug,
            Long userId,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                currentUser
                        );

        OrganizationMember actor =
                organizationMemberAccessService.getMember(
                        organization.getId(),
                        currentUser.getId()
                );

        OrganizationMember target =
                organizationMemberRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                userId
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Member not found"
                                )
                        );

        organizationMemberAccessService.validateCanRemoveMember(
                actor,
                target
        );

        organizationMemberRepository.delete(target);
    }

    @Transactional
    public void banUser(
            String slug,
            Long userId,
            BanRequest request,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(slug);

        OrganizationMember actor =
                organizationMemberAccessService.getMember(
                        organization.getId(),
                        currentUser.getId()
                );

        User targetUser =
                userRepository
                        .findById(userId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "User not found"
                                )
                        );

        if (
                organization.getOwner()
                        .getId()
                        .equals(targetUser.getId())
        ) {
            throw new BadRequestException(
                    "Organization owner cannot be banned"
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        LocalDateTime expiresAt =
                request.expiresAtFrom(
                        now
                );

        OrganizationBan existingBan =
                organizationBanRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                targetUser.getId()
                        )
                        .orElse(null);

        if (existingBan != null) {
            validateBanIsExpired(
                    existingBan.getExpiresAt(),
                    now
            );
        }

        OrganizationMember target =
                organizationMemberRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                targetUser.getId()
                        )
                        .orElse(null);

        organizationMemberAccessService.validateCanBanUser(
                actor,
                target
        );

        if (existingBan != null) {
            existingBan.setBannedByAppAdmins(null);
            existingBan.setBannedByOrgAdmins(
                    actor.getUser()
            );
            existingBan.setReason(
                    request.reason()
            );
            existingBan.setExpiresAt(
                    expiresAt
            );
            banNotificationEmailService.sendOrganizationUserBan(
                    targetUser,
                    organization,
                    request.reason(),
                    expiresAt
            );
            return;
        }

        organizationBanRepository.save(
                OrganizationBan.builder()
                        .organization(organization)
                        .user(targetUser)
                        .bannedByOrgAdmins(actor.getUser())
                        .reason(request.reason())
                        .expiresAt(expiresAt)
                        .build()
        );

        banNotificationEmailService.sendOrganizationUserBan(
                targetUser,
                organization,
                request.reason(),
                expiresAt
        );
    }

    @Transactional
    public void unbanUser(
            String slug,
            Long userId,
            User currentUser
    ) {

        Organization organization =
                organizationAccessService
                        .getBySlug(slug);

        organizationMemberAccessService.validateManager(
                organization.getId(),
                currentUser.getId()
        );

        User targetUser =
                userRepository
                        .findById(userId)
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "User not found"
                                )
                        );

        OrganizationBan ban =
                organizationBanRepository
                        .findByOrganizationIdAndUserId(
                                organization.getId(),
                                targetUser.getId()
                        )
                        .orElseThrow(() ->
                                new NotFoundException(
                                        "Ban not found"
                                )
                        );

        organizationBanRepository.delete(ban);
    }

    private void validateBanIsExpired(
            LocalDateTime expiresAt,
            LocalDateTime now
    ) {

        if (
                expiresAt == null
                        || expiresAt.isAfter(now)
        ) {
            throw new BadRequestException(
                    "User is already banned from this organization"
            );
        }
    }

}
