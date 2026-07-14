package app.lms.media.service;

import app.lms.common.exception.BadRequestException;
import app.lms.common.exception.ConflictException;
import app.lms.media.dto.PostMediaResponse;
import app.lms.media.dto.UploadedFile;
import app.lms.media.enums.FileType;
import app.lms.media.exception.ImageUploadException;
import app.lms.media.mapper.PostMediaMapper;
import app.lms.media.model.PostMedia;
import app.lms.media.repository.PostMediaRepository;
import app.lms.organization.model.Organization;
import app.lms.organization.service.OrganizationAccessService;
import app.lms.post.model.Post;
import app.lms.post.service.PostAccessService;
import app.lms.user.model.User;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


@Service
@RequiredArgsConstructor
public class PostMediaService {

    private final PostMediaRepository
            postMediaRepository;

    private final PostAccessService
            postAccessService;

    private final PostMediaAccessService
            postMediaAccessService;

    private final MediaService mediaService;

    private final PostMediaMapper
            postMediaMapper;
    private final OrganizationAccessService
            organizationAccessService;

    @Transactional
    public PostMediaResponse create(

            String slug,
            MultipartFile file,
            User user
    ) {

        Organization organization =
                organizationAccessService
                        .getManageableOrganization(
                                slug,
                                user
                        );

        String mediaName =
                generateAvailableMediaName(
                        organization.getId(),
                        getOriginalFileName(file)
                );

        FileType type =
                detectFileType(file);

        UploadedFile uploaded =
                mediaService.upload(
                        file,
                        "/posts/" + slug,
                        type
                );

        PostMedia media =
                buildMedia(
                        mediaName,
                        uploaded,
                        type,
                        organization
                );

        postMediaRepository.save(
                media
        );

        return postMediaMapper
                .toResponse(media);
    }

    @Transactional
    public PostMediaResponse update(

            Long mediaId,
            MultipartFile file,
            String name,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                mediaId,
                                user
                        );

        if (file == null && name == null) {
            throw new BadRequestException(
                    "File or name is required"
            );
        }

        if (name != null) {

            String newName =
                    normalizeMediaName(
                            name
                    );

            if (
                    postMediaRepository
                            .existsByOrganizationIdAndNameIgnoreCaseAndIdNot(
                                    media.getOrganization().getId(),
                                    newName,
                                    media.getId()
                            )
            ) {
                throw new ConflictException(
                        "Media name already exists in this post"
                );
            }

            media.setName(
                    newName
            );
        }

        if (file != null) {

            String oldFileId =
                    media.getFileId();

            FileType type =
                    detectFileType(file);

            UploadedFile uploaded =
                    mediaService.upload(
                            file,
                            "/posts/" +
                                    media.getOrganization().getId(),
                            type
                    );

            media.setUrl(
                    uploaded.url()
            );

            media.setFileId(
                    uploaded.fileId()
            );

            media.setType(
                    type
            );

            if (oldFileId != null) {

                try {
                    mediaService.delete(
                            oldFileId
                    );
                } catch (Exception ignored) {
                }
            }
        }

        return postMediaMapper
                .toResponse(media);
    }

    @Transactional
    public void delete(

            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getEditableMedia(
                                mediaId,
                                user
                        );

        if (media.getFileId() != null) {

            mediaService.delete(
                    media.getFileId()
            );
        }

        postMediaRepository.delete(
                media
        );
    }

    private String normalizeMediaName(
            String name
    ) {

        if (name == null || name.isBlank()) {
            throw new BadRequestException(
                    "Media name is required"
            );
        }

        return name.trim();
    }
    private String getOriginalFileName(
            MultipartFile file
    ) {

        if (
                file == null ||
                        file.getOriginalFilename() == null ||
                        file.getOriginalFilename().isBlank()
        ) {
            throw new ImageUploadException(
                    "File name is required"
            );
        }

        return file.getOriginalFilename()
                .trim();
    }

    private PostMedia buildMedia(

            String name,
            UploadedFile uploaded,
            FileType type,
            Organization organization
    ) {

        return PostMedia.builder()
                .name(name)
                .url(uploaded.url())
                .fileId(uploaded.fileId())
                .type(type)
                .organization(organization)
                .build();
    }

    public Page<PostMediaResponse> list(

            Long postId,
            Pageable pageable,
            User user
    ) {

        Post post =
                postAccessService
                        .getEditablePost(
                                postId,
                                user
                        );

        return postMediaRepository
                .findAllByOrganizationIdOrderByCreatedAtDesc(
                        post.getId(),
                        pageable
                )
                .map(
                        postMediaMapper::toResponse
                );
    }

    public PostMediaResponse getById(

            Long mediaId,
            User user
    ) {

        PostMedia media =
                postMediaAccessService
                        .getAccessibleMedia(
                                mediaId,
                                user
                        );

        return postMediaMapper
                .toResponse(
                        media
                );
    }
    private FileType detectFileType(
            MultipartFile file
    ) {

        if (file == null) {

            throw new ImageUploadException(
                    "File is required"
            );
        }

        String contentType =
                file.getContentType();

        if (
                contentType != null
                        &&
                        contentType.startsWith(
                                "image/"
                        )
        ) {

            return FileType.IMAGE;
        }

        if (
                contentType != null
                        &&
                        contentType.startsWith(
                                "video/"
                        )
        ) {

            return FileType.VIDEO;
        }

        return FileType.FILE;
    }


    private String extractBaseName(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return fileName;
        }

        return fileName.substring(
                0,
                dotIndex
        );
    }

    private String extractExtension(
            String fileName
    ) {

        int dotIndex =
                fileName.lastIndexOf(".");

        if (dotIndex <= 0) {
            return "";
        }

        return fileName.substring(
                dotIndex
        );
    }
    private String generateAvailableMediaName(
            Long postId,
            String originalName
    ) {

        String cleanName =
                originalName.trim();

        if (
                !postMediaRepository
                        .existsByOrganizationIdAndNameIgnoreCase(
                                postId,
                                cleanName
                        )
        ) {
            return cleanName;
        }

        String baseName =
                extractBaseName(cleanName);

        String extension =
                extractExtension(cleanName);

        int counter = 1;

        String candidate;

        do {
            candidate =
                    baseName +
                            " (" +
                            counter +
                            ")" +
                            extension;

            counter++;

        } while (
                postMediaRepository
                        .existsByOrganizationIdAndNameIgnoreCase(
                                postId,
                                candidate
                        )
        );

        return candidate;
    }
}


