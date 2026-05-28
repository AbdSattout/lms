package app.lms.organization.service;

import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
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

import java.util.List;

@Service
@RequiredArgsConstructor
public class OrganizationService {

    private final OrganizationRepository organizationRepository;
    private final OrganizationMemberRepository memberRepository;
    private final MediaService mediaService;
    private final OrganizationMapper organizationMapper;

    @Transactional
    public OrganizationResponse create(
            CreateOrganizationRequest request,
            MultipartFile image,
            User user
    ) {

        if (organizationRepository.existsByName(request.getName())) {
            throw new IllegalStateException(
                    "Organization name already exists"
            );
        }

        if (organizationRepository.existsByName(request.getName())) {
            throw new IllegalStateException(
                    "Name already exists"
            );
        }

        String imageUrl = null;
        String imageFileId = null;

        if (image != null && !image.isEmpty()) {

            UploadedFile uploaded =
                    mediaService.upload(
                            image,
                            "/organizations",
                            FileType.IMAGE
                    );

            imageUrl = uploaded.url();
            imageFileId = uploaded.fileId();
        }

        Organization organization = Organization.builder()
                .name(request.getName())
                .description(request.getDescription())
                .imageUrl(imageUrl)
                .imageFileId(imageFileId)
                .visibility(
                        request.getVisibility() == null
                                ? Visibility.PUBLIC
                                : request.getVisibility()
                )
                .owner(user)
                .build();

        organizationRepository.save(organization);

        OrganizationMember owner =
                OrganizationMember.builder()
                        .organization(organization)
                        .user(user)
                        .role(Role.OWNER)
                        .build();

        memberRepository.save(owner);

        return organizationMapper.ToResponse(organization);
    }

    public OrganizationResponse getByName(String name) {

        Organization organization =
                organizationRepository.findByName(name)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Organization not found"
                                )
                        );

        return organizationMapper.ToResponse(organization);
    }

    public List<OrganizationResponse> getAll() {

        return organizationRepository.findAll()
                .stream()
                .map(organizationMapper::ToResponse)
                .toList();
    }

    @Transactional
    public OrganizationResponse update(
            String name,
            UpdateOrganizationRequest request,
            MultipartFile image,
            User user
    ) {

        Organization organization =
                organizationRepository.findByName(name)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Organization not found"
                                )
                        );

        if (!organization.getOwner().getId().equals(user.getId())) {
            throw new IllegalStateException(
                    "You are not allowed"
            );
        }

        if (image != null && !image.isEmpty()) {

            UploadedFile uploaded =
                    mediaService.upload(
                            image,
                            "/organizations",
                            FileType.IMAGE
                    );

            if (organization.getImageFileId() != null) {

                mediaService.delete(
                        organization.getImageFileId()
                );
            }

            organization.setImageUrl(uploaded.url());
            organization.setImageFileId(uploaded.fileId());
        }

        if (request.getName() != null) {
            organization.setName(request.getName());
        }

        if (request.getDescription() != null) {
            organization.setDescription(request.getDescription());
        }

        if (request.getVisibility() != null) {
            organization.setVisibility(request.getVisibility());
        }

        return organizationMapper.ToResponse(organization);
    }

    @Transactional
    public void delete(
            String name,
            User user
    ) {

        Organization organization =
                organizationRepository.findByName(name)
                        .orElseThrow(() ->
                                new IllegalStateException(
                                        "Organization not found"
                                )
                        );

        if (!organization.getOwner().getId().equals(user.getId())) {
            throw new IllegalStateException(
                    "You are not allowed"
            );
        }
        if (organization.getImageFileId() != null) {

            mediaService.delete(
                    organization.getImageFileId()
            );
        }

        organizationRepository.delete(organization);
    }

}
