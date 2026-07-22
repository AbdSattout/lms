package app.lms.media.service;

import app.lms.media.dto.PostMediaResponse;
import app.lms.media.mapper.PostMediaMapper;
import app.lms.media.model.OrganizationMedia;
import app.lms.media.model.PostMedia;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
public class DashboardPostMediaService {

    private final PostMediaRepository postMediaRepository;
    private final PostMediaAccessService postMediaAccessService;
    private final PostMediaMapper postMediaMapper;
    private final OrganizationAccessService organizationAccessService;
    private final DashboardMediaStorageService mediaStorageService;

    @Transactional
    public PostMediaResponse create(
            Long organizationId,
            MultipartFile file,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationId,
                                user
                        );

        PostMedia media =
                buildMedia(
                        organization,
                        file
                );

        postMediaRepository.save(media);

        return postMediaMapper.toResponse(media);
    }

    @Transactional
    public PostMediaResponse update(
            Long organizationId,
            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                organizationId,
                                mediaId,
                                user
                        );

        mediaStorageService.validateUpdateRequest(
                file,
                name
        );

        if (name != null) {
            updateName(
                    media,
                    name
            );
        }

        if (file != null) {
            updateFile(
                    media,
                    file
            );
        }

        return postMediaMapper.toResponse(media);
    }

    @Transactional
    public void delete(
            Long organizationId,
            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                organizationId,
                                mediaId,
                                user
                        );

        OrganizationMedia organizationMedia =
                media.getOrganizationMedia();

        mediaStorageService.deletePostMediaFileIfUnused(
                organizationMedia
        );

        postMediaRepository.delete(media);
    }

    public PostMediaResponse getById(
            Long organizationId,
            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                organizationId,
                                mediaId,
                                user
                        );

        return postMediaMapper.toResponse(media);
    }

    public Page<PostMediaResponse> list(
            Long organizationId,
            Pageable pageable,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                organizationId,
                                user
                        );

        return postMediaRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        organization.getId(),
                        pageable
                )
                .map(postMediaMapper::toResponse);
    }

    private void updateName(
            PostMedia media,
            String name
    ) {

        mediaStorageService.rename(
                media.getOrganizationMedia(),
                media.getOrganization().getId(),
                name,
                "Media name already exists in this organization"
        );
    }

    private void updateFile(
            PostMedia media,
            MultipartFile file
    ) {

        mediaStorageService.replaceFile(
                media.getOrganization(),
                media.getOrganizationMedia(),
                file,
                "/posts/" + media.getOrganization().getId()
        );
    }

    private PostMedia buildMedia(
            Organization organization,
            MultipartFile file
    ) {

        OrganizationMedia organizationMedia =
                mediaStorageService.upload(
                        organization,
                        file,
                        "/posts/" + organization.getId()
                );

        return PostMedia.builder()
                .organization(organization)
                .organizationMedia(organizationMedia)
                .build();
    }

}
